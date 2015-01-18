{% extends "templates/base.volt" %}
{% block extra_js %}
    {{ javascript_include("/js/highcharts/highcharts.js") }}
    {{ javascript_include("/js/timepicker.js") }}
    <script language="JavaScript">
        $(function() {
            $("#date").datepicker({ dateFormat: "yymmdd" });
        });
    </script>
    {% endblock %}
{% block content %}
    {% if pie_data is defined %}
    {{ partial("templates/chart_pie",
    [
        'contain': 'level_map_pie',
        'title': '用户分布状况(全体)',
        'pie_data': pie_data,
        'series_name': '用户比例'
    ])
    }}
    {% endif %}
    {% if pie_data_new is defined %}
        {{ partial("templates/chart_pie",
        [
        'contain': 'level_map_pie_new',
        'title': '用户分布状况(今日新增)',
        'pie_data': pie_data_new,
        'series_name': '用户比例'
        ])
        }}
    {% endif %}
    {% if (column_keys is defined) and (column_values is defined) %}
    {{ partial("templates/chart_column",
    [
    'contain': 'level_map_column',
    'title': '用户分布状况(全体)',
    'key': column_keys,
    'value': column_values
    ])
    }}
    {% endif %}
    {% if (column_keys_new is defined) and (column_values_new is defined) %}
        {{ partial("templates/chart_column",
        [
        'contain': 'level_map_column_new',
        'title': '用户分布状况(今日新增)',
        'key': column_keys_new,
        'value': column_values_new
        ])
        }}
    {% endif %}
    {% if notice['code'] != 403 %}
        <div id="cdt_form">
        {{ form('/kpi/level', 'method':'post', 'id':'myform', 'name':'myform') }}
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
                        <label>请选择日期</label>
                        {{ text_field("date", "readonly": "readonly") }}
                    </td>
                </tr>
                <tr>
                    <td colspan="5" style="text-align: center;">
                        {{ submit_button("查询", "id": "sub_btn", "name": "sub_btn") }}
                    </td>
                </tr>
            </table>
            {{ hidden_field(security.getTokenKey(), "value": security.getToken()) }}
        </fieldset>
        {{ end_form() }}
    </div>
    {% endif %}
    <div id="level_map_pie"></div>
    <div id="level_map_pie_new"></div>
    <div id="level_map_column"></div>
    <div id="level_map_column_new"></div>
{% endblock %}
