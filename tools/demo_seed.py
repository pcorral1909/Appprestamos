#!/usr/bin/env python3
import sqlite3
import sys
from datetime import datetime, timedelta

DB_PATH = sys.argv[1]
PRESTAMO_ID = int(sys.argv[2]) if len(sys.argv) > 2 else 6

FMT = "%Y-%m-%d %H:%M:%S"

def read_prestamo(conn, pid):
    c = conn.cursor()
    c.execute("SELECT id, monto, interes_mensual, fecha_primer_pago, plazo_meses FROM prestamos WHERE id = ?", (pid,))
    row = c.fetchone()
    if not row:
        raise SystemExit(f'Prestamo {pid} not found')
    id_, monto, interes, fecha_str, plazo = row
    # fecha_primer_pago stored as integer (epoch) or as text? In DB it's stored as int (unixepoch)
    try:
        # try as integer epoch
        fecha = datetime.fromtimestamp(int(fecha_str))
    except Exception:
        try:
            fecha = datetime.fromisoformat(fecha_str)
        except Exception:
            fecha = datetime.now()
    return {
        'id': id_, 'monto': float(monto), 'interes': float(interes or 0.0), 'fecha_primer_pago': fecha, 'plazo': int(plazo) if plazo else 12
    }


def print_amortizaciones(conn, pid):
    c = conn.cursor()
    print('\n=== Amortizaciones ===')
    rows = c.execute("SELECT id, prestamo_id, monto, datetime(fecha_pago, 'unixepoch') as fecha_pago, pagado FROM amortizaciones WHERE prestamo_id = ? ORDER BY fecha_pago", (pid,)).fetchall()
    if not rows:
        print('(ninguna)')
        return
    print('id | prestamo_id | monto | fecha_pago | pagado')
    for row in rows:
        print(f"{row['id']} | {row['prestamo_id']} | {row['monto']} | {row['fecha_pago']} | {row['pagado']}")


def print_abonos(conn, pid):
    c = conn.cursor()
    print('\n=== Abonos ===')
    rows = c.execute("SELECT id, prestamo_id, monto, datetime(fecha, 'unixepoch') as fecha, tipo FROM abonos WHERE prestamo_id = ? ORDER BY fecha", (pid,)).fetchall()
    if not rows:
        print('(ninguno)')
        return
    print('id | prestamo_id | monto | fecha | tipo')
    for row in rows:
        print(f"{row['id']} | {row['prestamo_id']} | {row['monto']} | {row['fecha']} | {row['tipo']}")


def epoch(dt):
    return int(dt.timestamp())


def advance_month_keep_day(from_date, months):
    month = from_date.month - 1 + months
    year = from_date.year + month // 12
    month = month % 12 + 1
    day = from_date.day
    # last day of target month
    import calendar
    last = calendar.monthrange(year, month)[1]
    day = min(day, last)
    return datetime(year, month, day, from_date.hour, from_date.minute, from_date.second)


def main():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    prestamo = read_prestamo(conn, PRESTAMO_ID)
    print('Prestamo:', prestamo)

    print_amortizaciones(conn, PRESTAMO_ID)
    print_abonos(conn, PRESTAMO_ID)

    # Define the demo actions: pay interest on 2025-12-24 (6900) and capital abono 10000 same date
    pay_date = datetime(2025,12,24,6,0,0)
    interest_amount = 6900.0
    capital_amount = 10000.0

    print('\n-- Inserting interest payment and capital abono...')
    cur = conn.cursor()
    # insert interest abono
    cur.execute('INSERT INTO abonos (prestamo_id, monto, fecha, tipo) VALUES (?, ?, ?, ?)', (PRESTAMO_ID, interest_amount, epoch(pay_date), 'interes'))
    # mark amortizacion as pagado if exists same date
    cur.execute("SELECT id FROM amortizaciones WHERE prestamo_id = ? AND date(datetime(fecha_pago, 'unixepoch')) = date(datetime(?, 'unixepoch')) LIMIT 1", (PRESTAMO_ID, epoch(pay_date)))
    r = cur.fetchone()
    if r:
        aid = r[0]
        cur.execute('UPDATE amortizaciones SET pagado = 1 WHERE id = ?', (aid,))
        print('Marked amortizacion id', aid, 'as pagado')
    else:
        # create amortizacion pagada
        cur.execute('INSERT INTO amortizaciones (prestamo_id, monto, fecha_pago, pagado) VALUES (?, ?, ?, ?)', (PRESTAMO_ID, interest_amount, epoch(pay_date), 1))
        print('Inserted amortizacion pagada for date', pay_date)

    # insert capital abono
    cur.execute('INSERT INTO abonos (prestamo_id, monto, fecha) VALUES (?, ?, ?)', (PRESTAMO_ID, capital_amount, epoch(pay_date)))

    conn.commit()

    print('\n-- Recalculating amortizaciones for next 12 months based on new capital...')
    # Compute principal after all capital abonos up to pay_date inclusive
    c = conn.cursor()
    c.execute("SELECT SUM(monto) as total FROM abonos WHERE prestamo_id = ? AND (tipo IS NULL OR tipo != 'interes') AND fecha <= ?", (PRESTAMO_ID, epoch(pay_date)))
    row = c.fetchone()
    total_capital_abonos = row[0] or 0.0
    principal = prestamo['monto'] - total_capital_abonos
    if principal < 0: principal = 0.0
    print('Principal after capital abonos on', pay_date.date(), '=', principal)

    # Delete non-pagadas amortizaciones for this prestamo
    c.execute('DELETE FROM amortizaciones WHERE prestamo_id = ? AND pagado = 0', (PRESTAMO_ID,))

    # Generate next 12 months amortizaciones from next month after pay_date
    # find next period start from prestamo.fecha_primer_pago relative to now: use advance_month_keep_day logic from DB
    # We'll start from the month after pay_date
    start = advance_month_keep_day(prestamo['fecha_primer_pago'], 0)
    # compute months since primer to pay_date
    months_since = (pay_date.year - start.year) * 12 + (pay_date.month - start.month)
    next_start = advance_month_keep_day(prestamo['fecha_primer_pago'], months_since + 1)

    meses = prestamo['plazo']
    if meses is None:
        meses = 12

    for i in range(meses):
        fechaPago = advance_month_keep_day(next_start, i)
        interes = principal * (prestamo['interes'] / 100.0)
        # Insert amortizacion (not pagada)
        c.execute('INSERT INTO amortizaciones (prestamo_id, monto, fecha_pago, pagado) VALUES (?, ?, ?, ?)', (PRESTAMO_ID, round(interes,2), epoch(fechaPago), 0))
        # principal doesn't change unless there are future capital abonos (not in this demo)

    conn.commit()

    print_amortizaciones(conn, PRESTAMO_ID)
    print_abonos(conn, PRESTAMO_ID)
    conn.close()

if __name__ == '__main__':
    main()
