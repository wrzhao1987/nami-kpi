<script language="JavaScript">
    $(function () {
        $('#{{ contain }}').highcharts({
            chart: {
                type: 'column',
                margin: [ 50, 50, 100, 80]
            },
            title: {
                text: '{{ title }}'
            },
            xAxis: {
                categories: {{ key }},
                labels: {
                    rotation: -45,
                    align: 'right',
                    style: {
                        fontSize: '13px',
                        fontFamily: 'Verdana, sans-serif'
                    }
                }
            },
            yAxis: {
                min: 0,
                title: {
                    text: '{{ title }}'
                }
            },
            legend: {
                enabled: false
            },
            tooltip: {
                pointFormat:
            {% if point_format is defined %}
                {{ point_format }}
            {% else %}
                '{series.name}: <b>{point.y}</b>',
            {% endif %}
            },
            {% if plot_options is defined %}
            plotOptions: {
                {{ plot_options }}
            },
            {% endif %}
            series: {{ value }}
        });
    });
</script>