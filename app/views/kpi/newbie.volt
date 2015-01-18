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
    {% if total_rate_keys is defined %}
    {{ partial("templates/chart_line",
    [
    'contain': 'total_rate',
    'title': '封闭引导通过率',
    'subtitle': '分步骤详细',
    'key': total_rate_keys,
    'value': total_rate_values,
    'y_title': '通过率(%)',
    'point_format': '{series.name}: <b>{point.y:.1f}%</b>'
    ])
    }}
    {{ partial("templates/chart_line",
    [
    'contain': 'step_rate',
    'title': '新手引导通过率',
    'subtitle': '分步骤详细',
    'key': step_rate_keys,
    'value': step_rate_values,
    'y_title': '通过率(%)',
    'point_format': '{series.name}: <b>{point.y:.1f}%</b>'
    ])
    }}
    {{ partial("templates/chart_column",
    [
    'contain': 'step_num',
    'title': '每步完成人数',
    'key': step_num_keys,
    'value': step_num_values
    ])
    }}
    {% endif %}
    {% if notice['code'] != 403 %}
        <div id="cdt_form">
            {{ form('/kpi/newbie', 'method':'post', 'id':'myform', 'name':'myform') }}
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
    <div id="total_rate"></div>
    <div id="step_rate"></div>
    <div id="step_num"></div>
{% endblock %}