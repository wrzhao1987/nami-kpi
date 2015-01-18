{% extends "templates/base.volt" %}
{% block extra_js %}
    {{ javascript_include("/js/timepicker.js") }}
    <script language="JavaScript">
        $(function() {
            $("fieldset input").addClass('ui-widget-content ui-corner-all');
            $("#servers").buttonset();
            $("#select_all").button();
            $("#sub_btn").button();
            $("#weight_slider").slider({
                range: "min",
                value: 3,
                min: 1,
                max: 50,
                slide: function (event, ui) {
                    $("#weight").val(ui.value);
                }
            });
            $("#start_date").datepicker({ dateFormat: "yy-mm-dd" });
            $("#start_time").timepicker();
            $("#end_date").datepicker({ dateFormat: "yy-mm-dd" });
            $("#end_time").timepicker();
        });
        function selectAll()
        {
            var checked = $("#select_all").prop('checked');
            if (checked) {
                $(":checkbox").each(function () {
                    $(this).prop('checked', true).button('refresh');
                });
            } else {
                $(":checkbox").each(function () {
                   $(this).prop('checked', false).button('refresh');
                });
            }
        }
    </script>
{% endblock %}
{% block extra_css %}
    {{ stylesheet_link("/css/timepicker.css") }}
{% endblock %}
{% block content %}
    {% if notice['code'] != 403 %}
        <div class="ui-layout-pane" style="margin-top:100px;">
        {{ form('/announce/add', 'method':'post', 'id':'myform', 'name':'myform') }}
        <fieldset>
                <table style="margin: 0 auto; width: 100%;" border="1">
                    <tr>
                        <td>
                            <label for="title">标题</label>
                        </td>
                        <td>
                            {{ text_field("title", "size":80) }}
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <label for="title">正文</label>
                        </td>
                        <td>
                            {{ text_area("content", "cols": 60, "rows": 10) }}
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <label>开始时间</label>
                        </td>
                        <td>
                            {{ text_field("start_date", "readonly": "readonly") }}
                            {{ text_field("start_time", "readonly": "readonly") }}
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <label>结束日期</label>
                        </td>
                        <td>
                            {{ text_field("end_date", "readonly": "readonly") }}
                            {{ text_field("end_time", "readonly": "readonly") }}
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <label>权重</label>
                        </td>
                        <td>
                            {{ text_field("weight", "readonly": "readonly") }}
                            <div id="weight_slider"></div>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <label for="servers">服务器列表</label>
                        </td>
                        <td>
                            <input type="checkbox" id="select_all" onclick="selectAll();" />
                            <label for="select_all">全选</label>
                            <div id="servers">
                                {% for server_id, server_name in server_list %}
                                    <input type="checkbox" id="server[{{ server_id }}]"
                                           name="server[{{ server_id }}]" value="{{ server_id }}"
                                    />
                                    <label for="server[{{ server_id }}]">{{ server_name }}</label>
                                {% endfor %}
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" style="text-align: center;">
                            {{ submit_button("发送", "id": "sub_btn", "name": "sub_btn") }}
                        </td>
                    </tr>
                </table>
            {{ hidden_field(security.getTokenKey(), "value": security.getToken()) }}
        </fieldset>
        {{ endform() }}
        </div>
    {% endif %}
{% endblock %}