{% extends "templates/base.volt" %}
{% block extra_js %}
    {{ javascript_include("/js/timepicker.js") }}
    <script language="JavaScript">
        $(function() {
            $("fieldset input").addClass('ui-widget-content ui-corner-all');
            $("#sub_btn").button();
            $("#weight_slider").slider({
                range: "min",
                value: {% if post.weight is defined %}{{ post.weight }}{% endif %},
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
    </script>
{% endblock %}
{% block content %}
    {% if notice['code'] != 403 %}
        {% if post is defined %}
        <div class="ui-layout-pane" style="margin-top:100px;">
            {{ form('/announce/edit', 'method':'post', 'id':'myform', 'name':'myform') }}
            <fieldset>
                    <table style="margin: 0 auto;" border="1">
                        <tr>
                            <td>
                                <label for="title">标题</label>
                            </td>
                            <td>
                                {{ text_field("title", "size":32, "value": post.title) }}
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <label for="title">正文</label>
                            </td>
                            <td>
                                {{ text_area("content", "value":post.content) }}
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <label>开始时间</label>
                            </td>
                            <td>
                                {{ text_field("start_date", "readonly": "readonly", "value":post.start_date) }}
                                {{ text_field("start_time", "readonly": "readonly", "value":post.start_time) }}
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <label>结束日期</label>
                            </td>
                            <td>
                                {{ text_field("end_date", "readonly": "readonly", "value": post.end_date) }}
                                {{ text_field("end_time", "readonly": "readonly", "value": post.end_time) }}
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <label>权重</label>
                            </td>
                            <td>
                                {{ text_field("weight", "readonly": "readonly", "value": post.weight) }}
                                <div id="weight_slider"></div>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" style="text-align: center;">
                                {{ submit_button("修改", "id": "sub_btn", "name": "sub_btn") }}
                            </td>
                        </tr>
                    </table>
                {{ hidden_field(security.getTokenKey(), "value": security.getToken()) }}
                {{ hidden_field('srv_id', "value": server_id) }}
                {{ hidden_field('id', "value": post.id) }}
            </fieldset>
        {{ end_form() }}
        </div>
        {% endif %}
    {% endif %}
{% endblock %}