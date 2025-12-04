#!/usr/bin/env python3
import sqlite3
import sys
import shutil
from datetime import datetime

DB_PATH = sys.argv[1]
PRESTAMO_ID = int(sys.argv[2]) if len(sys.argv) > 2 else 6

def backup_db(path):
    ts = datetime.now().strftime('%Y%m%d_%H%M%S')
    dest = f"{path}.backup.{ts}"
    shutil.copy2(path, dest)
    return dest

def epoch(dt):
    return int(dt.timestamp())

def advance_month_keep_day(from_date, months):
    month = from_date.month - 1 + months
    year = from_date.year + month // 12
    month = month % 12 + 1
    day = from_date.day
    import calendar
    last = calendar.monthrange(year, month)[1]
    day = min(day, last)
    return datetime(year, month, day, from_date.hour, from_date.minute, from_date.second)

if __name__ == '__main__':
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    print('Backing up DB...')
    backup = backup_db(DB_PATH)
    print('Backup created at', backup)

    cur = conn.cursor()
    # Read prestamo
    cur.execute('SELECT id, monto, interes_mensual, fecha_primer_pago, plazo_meses FROM prestamos WHERE id = ?', (PRESTAMO_ID,))
    row = cur.fetchone()
    if not row:
        print('Prestamo not found:', PRESTAMO_ID)
        sys.exit(1)
    monto = float(row['monto'])
    interes = float(row['interes_mensual'] or 0.0)
    fecha_raw = row['fecha_primer_pago']
    try:
        fecha = datetime.fromtimestamp(int(fecha_raw))
    except Exception:
        try:
            fecha = datetime.fromisoformat(fecha_raw)
        except Exception:
            fecha = datetime.now()
    plazo = int(row['plazo_meses'] or 12)

    print(f'Resetting prestamo {PRESTAMO_ID}: monto={monto}, interes={interes}, fecha={fecha}, plazo={plazo}')

    # Delete abonos and amortizaciones for prestamo
    cur.execute('DELETE FROM abonos WHERE prestamo_id = ?', (PRESTAMO_ID,))
    cur.execute('DELETE FROM amortizaciones WHERE prestamo_id = ?', (PRESTAMO_ID,))
    conn.commit()
    print('Deleted existing abonos and amortizaciones for prestamo', PRESTAMO_ID)

    # Generate amortizaciones: one per month, interest on full principal
    for i in range(plazo):
        fechaPago = advance_month_keep_day(fecha, i)
        interes_mes = round(monto * (interes / 100.0), 2)
        cur.execute('INSERT INTO amortizaciones (prestamo_id, monto, fecha_pago, pagado) VALUES (?, ?, ?, ?)',
                    (PRESTAMO_ID, interes_mes, epoch(fechaPago), 0))
    conn.commit()
    print('Inserted', plazo, 'amortizaciones (un mes cada una)')

    # Print summary
    rows = cur.execute("SELECT id, prestamo_id, monto, datetime(fecha_pago,'unixepoch') as fecha_pago, pagado FROM amortizaciones WHERE prestamo_id = ? ORDER BY fecha_pago", (PRESTAMO_ID,)).fetchall()
    print('\nCurrent amortizaciones:')
    for r in rows:
        print(r['id'], r['monto'], r['fecha_pago'], r['pagado'])

    rows = cur.execute("SELECT id, prestamo_id, monto, datetime(fecha,'unixepoch') as fecha, tipo FROM abonos WHERE prestamo_id = ? ORDER BY fecha", (PRESTAMO_ID,)).fetchall()
    print('\nCurrent abonos:')
    if not rows:
        print('(none)')
    else:
        for r in rows:
            print(r['id'], r['monto'], r['fecha'], r['tipo'])

    conn.close()
    print('\nDone')
