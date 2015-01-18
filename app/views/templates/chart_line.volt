<script language="JavaScript">
    $(function () {
        $('#{{ contain }}').highcharts({
            chart: {
                type: 'line'
            },
            title: {
                text: '{{ title }}'
            },
            subtitle: {
                text: '{{ subtitle }}'
            },
            xAxis: {
                categories: {{ key }}
            },
            yAxis: {
                title: {
                    text: '{{ y_title }}'
                }
            },
            tooltip: {
                enabled: true,
                pointFormat: '{{ point_format }}'
            },
            plotOptions: {
                line: {
                    dataLabels: {
                        enabled: true
                    },
                    enableMouseTracking: true
                }
            },
            series: {{ value }}
        });
    });
</script>