{% extends "templates/base.volt" %}
{% block extra_js %}
    <script language="JavaScript">
        $(function() {
            $("#sub_btn").button();
            $("#role_radio").buttonset();
        });
    </script>
{% endblock %}
{% block content %}
    {% if notice['code'] != 403 %}
        {{ form('/admin/add', 'method':'post') }}
        <fieldset>
            <div class="ui-layout-pane" style="margin-top:100px;">
                <table  style="margin: 0 auto;">
                    <tr>
                        <td>
                            <label for="name">用户名:</label>
                        </td>
                        <td>
                            {{ text_field("name", "size":32, "class":"ui-widget-content ui-corner-all") }}
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <label for="pwd_1">密码:</label>
                        </td>
                        <td>
                            {{ password_field("pwd_1", "size":32, "class": "ui-widget-content ui-corner-all") }}
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <label for="pwd_2">请再输入一次:</label>
                        </td>
                        <td>
                            {{ password_field("pwd_2", "size":32, "class": "ui-widget-content ui-corner-all") }}
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <label for="role">权限级别:</label>
                        </td>
                        <td id="role_radio">
                            {% for role_id, role_name in roles %}
                                <input type="radio" name="role" id="role{{ role_id }}" value="{{ role_id }}" />
                                <label for="role{{ role_id }}">{{ role_name }}</label>
                            {% endfor %}
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" style="text-align: center;">
                            {{ submit_button("添加", "id": "sub_btn", "name": "sub_btn") }}
                        </td>
                    </tr>
                </table>
            </div>
            {{ hidden_field(security.getTokenKey(), "value":security.getToken()) }}
        </fieldset>
        {{ end_form() }}
    {% endif %}
{% endblock %}