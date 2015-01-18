{% extends "templates/base.volt" %}
{% block extra_js %}
    {{ javascript_include("/js/dt/jquery.dataTables.min.js") }}
    {{ javascript_include("/js/dt/dataTables.jqueryui.js") }}
    <script language="JavaScript">
        $(function() {
            $('#admin-form').dataTable();
        });
    </script>
{% endblock %}
{% block extra_css %}
    {{ stylesheet_link("/css/dt/dataTables.jqueryui.css") }}
{% endblock %}
{% block content %}
    {% if notice['code'] != 403 %}
        {{ form('/admin/manage', 'method': 'post') }}
        <table id="admin-form" class="display" style="text-align: center;">
            <thead>
                <tr>
                    <th>UID</th>
                    <th>用户名</th>
                    <th>权限</th>
                    <th>激活状态</th>
                    <th>添加时间</th>
                    <th>备注</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
            {% for admin in admins %}
                {% if (admin.name != name) and (role < admin.role) %}
                <tr id="{{ "item" ~ admin.id }}">
                    <td><label>{{ admin.id }}</label></td>
                    <td><label>{{ admin.name }}</label></td>
                    <td><label>{{ roles_view[admin.role] }}</label></td>
                    <td>
                        <label>
                            {% if admin.active %}
                                激活
                            {% else %}
                                冻结
                            {% endif %}
                        </label>
                    </td>
                    <td><label>{{ admin.added_at }}</label></td>
                    <td><label>{{ admin.note }}</label></td>
                    <td>
                        {% if (role == 1 or role == 2) and role < admin.role %}
                            {{ link_to("/admin/edit?uid=" ~ admin.id, "编辑") }}
                        {% endif %}
                    </td>
                </tr>
                {% endif %}
            {% endfor %}
            </tbody>
        </table>
        {{ hidden_field(security.getTokenKey(), "value":security.getToken()) }}
        {{ end_form() }}
    {% endif %}
{% endblock %}