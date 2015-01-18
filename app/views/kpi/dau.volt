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
    {% if column_keys is defined and column_values is defined %})
    {{ partial("templates/chart_column",
    [
    'contain': 'dau',
    'title': '日活跃用户数',
    'key': column_keys,
    'value': column_values,
    'plot_options': "
        column: {
            stacking: 'normal',
            dataLabels: {
                enabled: true,
                color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
            }
        }"
    ])
    }}
    {% endif %}
    {% if notice['code'] != 403 %}
        <div id="cdt_form">
            {{ form('/kpi/dau', 'method':'post', 'id':'myform', 'name':'myform') }}
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
    <div id="dau"></div>
{% endblock %}