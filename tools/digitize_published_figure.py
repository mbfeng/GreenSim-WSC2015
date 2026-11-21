"""Read the plotted values of Figure 2 from the paper's vector figure.

One-off provenance tool. Figure 2 of the paper (Figures/msefig.eps in the
paper's LaTeX source, MATLAB R2014b output) is a vector figure, so the plotted
MSE curves can be read from it exactly, to the precision of the coordinates
printed in the file (about 1e-10 in MSE units).

Usage:  python digitize_published_figure.py <msefig.eps> <output.csv>
Output: CSV with columns Week, SMC, OIS, MIS (the three curves, weeks 1-26).

Calibration (inner coordinates of the plot, before the 0.7875 scaling): the
x-axis runs from week 0 at x = 218 to week 27 at x = 1520; the y-axis from
MSE 0 at y = 723 to MSE 1.4e-4 at y = 61 (tick labels 0, 0.2, ..., 1.4, x 1e-4).
"""
import csv
import re
import sys

X0, X1, WEEK1 = 218.0, 1520.0, 27.0       # x pixel of week 0 and of week 27
Y0, Y1, MSE1 = 723.0, 61.0, 1.4e-4        # y pixel of MSE 0 and of MSE 1.4e-4
COLOURS = {                                # line colours of the three curves
    '0 0.447 0.741': 'SMC',
    '0.929 0.694 0.125': 'OIS',
    '0.851 0.325 0.098': 'MIS',
}
POINT = re.compile(r'^(-?[\d.]+) (-?[\d.]+) ([ML])$')


def polylines(lines):
    """Yield (colour, points) for every path drawn with M/L commands."""
    colour, points = None, []
    for line in lines:
        text = line.strip()
        match = POINT.match(text)
        if match:
            if match.group(3) == 'M' and points:
                yield colour, points
                points = []
            points.append((float(match.group(1)), float(match.group(2))))
        elif text in ('S', 'GR'):
            if points:
                yield colour, points
                points = []
        elif text.endswith(' RC'):
            colour = text[:-3]


def main(eps_file, csv_file):
    with open(eps_file, encoding='latin-1') as handle:
        lines = handle.read().splitlines()
    curves = {}
    for colour, points in polylines(lines):
        name = COLOURS.get(colour)
        if name and len(points) >= 20:        # the curves, not error bars
            curves[name] = points
    if sorted(curves) != ['MIS', 'OIS', 'SMC']:
        raise SystemExit(f'expected three curves, found {sorted(curves)}')
    num_weeks = len(curves['SMC'])
    rows = []
    for k in range(num_weeks):
        x_pixel = curves['SMC'][k][0]
        week = (x_pixel - X0) / (X1 - X0) * WEEK1
        row = {'Week': round(week)}
        for name in ('SMC', 'OIS', 'MIS'):
            y_pixel = curves[name][k][1]
            row[name] = f'{(Y0 - y_pixel) / (Y0 - Y1) * MSE1:.10e}'
        rows.append(row)
    with open(csv_file, 'w', newline='') as handle:
        writer = csv.DictWriter(handle, fieldnames=['Week', 'SMC', 'OIS', 'MIS'])
        writer.writeheader()
        writer.writerows(rows)
    print(f'{num_weeks} weeks written to {csv_file}')


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
