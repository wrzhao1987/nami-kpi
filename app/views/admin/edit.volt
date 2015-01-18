{% extends "templates/base.volt" %}
{% block extra_js %}
    <script language="JavaScript">
        $(function() {
            $("#sub_btn").button();
            $("#role_radio").buttonset();
            $("#active_radio").buttonset();
        });
    </script>
{% endblock %}
{% block content %}
    {% if notice['code'] != 403 %}
        {{ form('/admin/edit', 'method':'post') }}
        <div class="ui-layout-pane" style="margin-top:100px;">
            <table style="margin: 0 auto;">
                <tr>
                    <td>
                        <label>用户名:</label>
                    </td>
                    <td>
                        <label>{{ edit_user.name }}</label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label>权限:</label>
                    </td>
                    <td>
                        <div id="role_radio">
                            {% for role_id, role_name in roles %}
                                <input type="radio" name="role" id="role{{ role_id }}" value="{{ role_id }}"
                                {% if edit_user.role == role_id %}checked="checked"{% endif %} />
                                <label for="role{{ role_id }}">{{ role_name }}</label>
                            {% endfor %}
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label>激活状态:</label>
                    </td>
                    <td>
                        <div id="active_radio">
                            <input type="radio" name="active" id="active0" value="0" {% if edit_user.active == 0 %}checked="checked" {% endif %} /><label for="active0">冻结</label>
                            <input type="radio" name="active" id="active1" value="1" {% if edit_user.active == 1 %}checked="checked" {% endif %}/><label for="active1">激活</label>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label>备注:</label>
                    </td>
                    <td>
                        {{ text_area("note", "value": edit_user.note) }}
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        {{ submit_button("发公告", "id": "sub_btn", "name": "sub_btn") }}
                    </td>
                </tr>
            </table>
        </div>
        {{ hidden_field(security.getTokenKey(), "value": security.getToken()) }}
        {{ hidden_field('uid', "value": edit_user.id) }}
        {{ end_form() }}
    {% endif %}
{% endblock %}