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
    {% if normal_col_keys is defined %}
    {{ partial("templates/chart_column",
    [
    'contain': 'mission_map_normal',
    'title': '普通副本章节分布(总体)',
    'key': normal_col_keys,
    'value': normal_col_values
    ])
    }}
    {% endif %}
    {% if normal_col_keys_new is defined %}
        {{ partial("templates/chart_column",
        [
        'contain': 'mission_map_normal_new',
        'title': '普通副本章节分布(新增)',
        'key': normal_col_keys_new,
        'value': normal_col_values_new
        ])
        }}
    {% endif %}
    {% if elite_col_keys is defined %}
    {{ partial("templates/chart_column",
    [
    'contain': 'mission_map_elite',
    'title': '精英副本章节分布(总体)',
    'key': elite_col_keys,
    'value': elite_col_values
    ])
    }}
    {% endif %}
    {% if elite_col_keys_new is defined %}
        {{ partial("templates/chart_column",
        [
        'contain': 'mission_map_elite_new',
        'title': '精英副本章节分布(新增)',
        'key': elite_col_keys_new,
        'value': elite_col_values_new
        ])
        }}
    {% endif %}
    {% if notice['code'] != 403 %}
        <div id="cdt_form">
            {{ form('/kpi/mission', 'method':'post', 'id':'myform', 'name':'myform') }}
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
    <div id="mission_map_normal"></div>
    <div id="mission_map_normal_new"></div>
    <div id="mission_map_elite"></div>
    <div id="mission_map_elite_new"></div>
{% endblock %}