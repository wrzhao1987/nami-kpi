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
    {% if keys is defined and p_data is defined and c_data is defined %}
    {{ partial("templates/chart_line",
    [
    'contain': 'item_produce',
    'title': '道具产出',
    'subtitle': '按照道具分类',
    'key': keys,
    'value': p_data,
    'y_title': '产出数量',
    'point_format': '{series.name}: <b>{point.y}</b>'
    ])
    }}
    {{ partial("templates/chart_line",
    [
    'contain': 'item_consume',
    'title': '道具消费',
    'subtitle': '按照道具分类',
    'key': keys,
    'value': c_data,
    'y_title': '消费数量',
    'point_format': '{series.name}: <b>{point.y}</b>'
    ])
    }}
    {% endif %}
    {% if notice['code'] != 403 %}
        <div id="cdt_form">
            {{ form('/kpi/item', 'method':'post', 'id':'myform', 'name':'myform') }}
            <fieldset>
                <table style="margin: 0 auto; width: 100%;" border="1">
                    <tr>
                        <td colspan="2">
                            <label>请选择服务器:</label>
                            {{ select_static("srv_id", srv_list) }}
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
    <div id="item_produce"></div>
    <div id="item_consume"></div>
{% endblock %}