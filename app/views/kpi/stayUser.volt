{% extends "templates/base.volt" %}
{% block extra_js %}
    {{ javascript_include("/js/highcharts/highcharts.js") }}
{% endblock %}
{% block content %}
    {{ partial("templates/chart_line",
    [
    'contain': 'stay_1',
    'title': '次日留存率',
    'subtitle': '按天计算',
    'key': line_keys,
    'value': line_values_d1,
    'y_title': '留存率(%)',
    'point_format': '{series.name}: <b>{point.y:.2f}%</b>'
    ])
    }}
    {{ partial("templates/chart_line",
    [
    'contain': 'stay_3',
    'title': '3日留存率',
    'subtitle': '按天计算',
    'key': line_keys,
    'value': line_values_d3,
    'y_title': '留存率(%)',
    'point_format': '{series.name}: <b>{point.y:.2f}%</b>'
    ])
    }}
    {{ partial("templates/chart_line",
    [
    'contain': 'stay_7',
    'title': '7日留存率',
    'subtitle': '按天计算',
    'key': line_keys,
    'value': line_values_d7,
    'y_title': '留存率(%)',
    'point_format': '{series.name}: <b>{point.y:.2f}%</b>'
    ])
    }}
    {{ partial("templates/chart_line",
    [
    'contain': 'stay_15',
    'title': '15日留存率',
    'subtitle': '按天计算',
    'key': line_keys,
    'value': line_values_d15,
    'y_title': '留存率(%)',
    'point_format': '{series.name}: <b>{point.y:.2f}%</b>'
    ])
    }}
    {{ partial("templates/chart_line",
    [
    'contain': 'stay_30',
    'title': '30日留存率',
    'subtitle': '按天计算',
    'key': line_keys,
    'value': line_values_d30,
    'y_title': '留存率(%)',
    'point_format': '{series.name}: <b>{point.y:.2f}%</b>'
    ])
    }}
    <div id="stay_1"></div>
    <div id="stay_3"></div>
    <div id="stay_7"></div>
    <div id="stay_15"></div>
    <div id="stay_30"></div>
{% endblock %}