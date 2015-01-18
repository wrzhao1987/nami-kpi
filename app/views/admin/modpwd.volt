{% extends "templates/base.volt" %}
{% block extra_js %}
    <script language="JavaScript">
        $(function() {
            $("#sub_btn").button();
        });
    </script>
{% endblock %}
{% block content %}
    {% if notice['code'] != 403 %}
        {{ form('/admin/modpwd', 'method':'post') }}
        <div class="ui-layout-pane" style="margin-top:100px;">
            <table style="margin: 0 auto; text-align: center;">
                <tr>
                    <td>
                        <label for="old_pwd">原密码:</label>
                    </td>
                    <td>
                        {{ password_field("old_pwd", "size":32, "class":" ui-widget-content ui-corner-all") }}
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="new_pwd_1">新密码:</label>
                    </td>
                    <td>
                        {{ password_field("new_pwd_1", "size":32, "class":" ui-widget-content ui-corner-all") }}
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="new_pwd_2">再输入一次:</label>
                    </td>
                    <td>
                        {{ password_field("new_pwd_2", "size":32, "class":" ui-widget-content ui-corner-all") }}
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        {{ submit_button("修改", "id":"sub_btn") }}
                    </td>
                </tr>
            </table>
        </div>
        {{ end_form() }}
    {% endif %}
{% endblock %}