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
    {% if level_keys is defined %}
    {{ partial("templates/chart_column",
    [
    'contain': 'pay_level_map',
    'title': '首次付费等级分布',
    'key': level_keys,
    'value': level_values
    ])
    }}
    {% endif %}
    {% if period_keys is defined %}
    {{ partial("templates/chart_column",
    [
    'contain': 'pay_period_map',
    'title': '首次付费时间间隔分布',
    'key': period_keys,
    'value': period_values
    ])
    }}
    {% endif %}
    {% if notice['code'] != 403 %}
        <div id="cdt_form">
            {{ form('/kpi/payMap', 'method':'post', 'id':'myform', 'name':'myform') }}
            <fieldset>
                <table style="margin: 0 auto; width: 100%;" border="1">
                    <tr>
                        <td colspan="2">
                            <label>请选择服务器:</label>
                            {{ select_static("srv_id", srv_list) }}
                        </td>
                        <td colspan="2">
                            <label>请选择日期</label>
                            {{ text_field("date", "readonly": "readonly") }}
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4" style="text-align: center;">
                            {{ submit_button("查询", "id": "sub_btn", "name": "sub_btn") }}
                        </td>
                    </tr>
                </table>
                {{ hidden_field(security.getTokenKey(), "value": security.getToken()) }}
            </fieldset>
            {{ end_form() }}
        </div>
    {% endif %}
    <div id="pay_level_map"></div>
    <div id="pay_period_map"></div>
{% endblock %}