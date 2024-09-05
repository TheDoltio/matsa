import pandas as pd

data = pd.read_csv('per_min_ctn2608241046.dat', sep=' ', header=None, parse_dates=[[0, 1]], dayfirst=True)

data.columns = ['datetime', 'col3', 'col4', 'col5', 'col6', 'col7']

data['group_15min'] = (data['datetime'] - data['datetime'].min()).dt.total_seconds() // 900

grouped_15min = data.groupby('group_15min').agg({
    'datetime': 'first',
    'col3': ['mean', 'std'],
    'col4': ['mean', 'std'],
    'col5': ['mean', 'std'],
    'col6': ['mean', 'std'],
    'col7': ['mean', 'std']
})

grouped_15min.columns = ['_'.join(col).strip() for col in grouped_15min.columns.values]

grouped_15min['datetime_first'] = grouped_15min['datetime_first'].dt.strftime('%d-%m-%Y %H:%M:%S')

with open('per_15min_ctn.dat', 'w') as f:
    for _, row in grouped_15min.iterrows():
        f.write(f"{row['datetime_first']} {row['col3_mean']:.1f} {row['col3_std']:.1f} {row['col4_mean']:.2f} {row['col4_std']:.2f} {row['col5_mean']:.1f} {row['col5_std']:.1f} {row['col6_mean']:.1f} {row['col6_std']:.1f} {row['col7_mean']:.2f} {row['col7_std']:.2f}\n")

data['hour'] = data['datetime'].dt.floor('H')

grouped_hour = data.groupby('hour').agg({
    'col3': ['mean', 'std'],
    'col4': ['mean', 'std'],
    'col5': ['mean', 'std'],
    'col6': ['mean', 'std'],
    'col7': ['mean', 'std']
})

grouped_hour.columns = ['_'.join(col).strip() for col in grouped_hour.columns.values]

grouped_hour.reset_index(inplace=True)
grouped_hour['hour'] = grouped_hour['hour'].dt.strftime('%d-%m-%Y %H:%M:%S')

with open('per_hour_ctn.dat', 'w') as f:
    for _, row in grouped_hour.iterrows():
        f.write(f"{row['hour']} {row['col3_mean']:.1f} {row['col3_std']:.1f} {row['col4_mean']:.2f} {row['col4_std']:.2f} {row['col5_mean']:.1f} {row['col5_std']:.1f} {row['col6_mean']:.1f} {row['col6_std']:.1f} {row['col7_mean']:.2f} {row['col7_std']:.2f}\n")

data['day'] = data['datetime'].dt.date

grouped_day = data.groupby('day').agg({
    'col3': ['mean', 'std'],
    'col4': ['mean', 'std'],
    'col5': ['mean', 'std'],
    'col6': ['mean', 'std'],
    'col7': ['mean', 'std']
})

grouped_day.columns = ['_'.join(col).strip() for col in grouped_day.columns.values]

grouped_day.reset_index(inplace=True)
grouped_day['day'] = pd.to_datetime(grouped_day['day']).dt.strftime('%d-%m-%Y')

with open('per_day_ctn.dat', 'w') as f:
    for _, row in grouped_day.iterrows():
        f.write(f"{row['day']} {row['col3_mean']:.1f} {row['col3_std']:.1f} {row['col4_mean']:.2f} {row['col4_std']:.2f} {row['col5_mean']:.1f} {row['col5_std']:.1f} {row['col6_mean']:.1f} {row['col6_std']:.1f} {row['col7_mean']:.2f} {row['col7_std']:.2f}\n")

