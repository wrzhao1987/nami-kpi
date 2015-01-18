{% extends "templates/base.volt" %}
{% block extra_js %}
    {{ javascript_include("/js/highcharts/highcharts.js") }}
    {{ javascript_include("/js/timepicker.js") }}
    <script language="JavaScript">
        $(function() {
            $("#start_date").datepicker({ dateFormat: "yymmdd" });
            $("#end_date").datepicker({ dateFormat: "yymmdd" });
        });
    </script>
{% endblock %}
{% block content %}
    {% if keys is defined %}
        {{ partial("templates/chart_line",
        [
        'contain': 't_arpu',
        'title': '总ARPU',
        'subtitle': '分日期',
        'key': keys,
        'value': t_arpu,
        'y_title': '分',
        'point_format': '{series.name}: <b>{point.y:.1f}</b>'
        ])
        }}
        {{ partial("templates/chart_line",
        [
        'contain': 'n_arpu',
        'title': '新增ARPU',
        'subtitle': '分日期',
        'key': keys,
        'value': n_arpu,
        'y_title': '分',
        'point_format': '{series.name}: <b>{point.y:.1f}</b>'
        ])
        }}
        {{ partial("templates/chart_line",
        [
        'contain': 't_income',
        'title': '总收入',
        'subtitle': '分日期',
        'key': keys,
        'value': t_income,
        'y_title': '分',
        'point_format': '{series.name}: <b>{point.y:.1f}</b>'
        ])
        }}
        {{ partial("templates/chart_line",
        [
        'contain': 'n_income',
        'title': '新增收入',
        'subtitle': '分日期',
        'key': keys,
        'value': n_income,
        'y_title': '分',
        'point_format': '{series.name}: <b>{point.y:.1f}</b>'
        ])
        }}
    {% endif %}
    {% if notice['code'] != 403 %}
        <div id="cdt_form">
            {{ form('/kpi/arpu', 'method':'post', 'id':'myform', 'name':'myform') }}
            <fieldset>
                <table style="margin: 0 auto; width: 100%;" border="1">
                    <tr>
                        <td colspan="2">
                            <label>请选择服务器:</label>
                            {{ select_static("srv_id", srv_list) }}
                        </td>
                        <td colspan="2">
                            <label>请选择平台:</label>
                            {{ select_static("src_id", src_list) }}
                        </td>
                        <td colspan="2">
                            <label>请选择开始日期</label>
                            {{ text_field("start_date", "readonly": "readonly") }}
                        </td>
                        <td colspan="2">
                            <label>请选择结束日期</label>
                            {{ text_field("end_date", "readonly": "readonly") }}
                        </td>
                    </tr>
                    <tr>
                        <td colspan="7" style="text-align: center;">
                            {{ submit_button("查询", "id": "sub_btn", "name": "sub_btn") }}
                        </td>
                    </tr>
                </table>
                {{ hidden_field(security.getTokenKey(), "value": security.getToken()) }}
            </fieldset>
            {{ end_form() }}
        </div>
    {% endif %}
    <div id="t_arpu"></div>
    <div id="n_arpu"></div>
    <div id="t_income"></div>
    <div id="n_income"></div>
{% endblock %}
