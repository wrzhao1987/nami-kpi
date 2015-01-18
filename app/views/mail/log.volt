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
    {% if logs is defined %}
        <div class="ui-layout-pane" style="margin-top:100px;">
            <table id="admin-form" class="display" border="1" style="text-align: center;">
                <thead>
                <tr>
                    <th>编号</th>
                    <th>操作人员</th>
                    <th>标题</th>
                    <th>正文</th>
                    <th>服务器ID</th>
                    <th>目标玩家</th>
                    <th>附件</th>
                    <th>发送时间</th>
                </tr>
                </thead>
                <tbody>
                {% for log in logs %}
                    <tr>
                        <td>{{ log['id'] }}</td>
                        <td>{{ log['username'] }}</td>
                        <td>{{ log['title'] }}</td>
                        <td>{{ log['content'] }}</td>
                        <td>{{ log['server_id'] }}</td>
                        <td>
                            {% if (log['to_users'] == 'NAMI-ALL') %}
                                所有玩家
                            {% else %}
                                <ul style="text-align: left;">
                                {% for user in log['to_users'] %}
                                    <li>{{ user }}</li>
                                {% endfor %}
                                </ul>
                            {% endif %}
                        </td>
                        <td>
                            <ul style="text-align: left;">
                                {% for attach in log['attachment'] %}
                                    <li>
                                        {{ item_names[attach['item_id']] }}
                                        {% if sub_names[attach['item_id']][attach['sub_id']] is defined %}
                                        - {{ sub_names[attach['item_id']][attach['sub_id']] }}
                                        {% endif %}
                                        X {{ attach['count'] }}
                                    </li>
                                {% endfor %}
                            </ul>
                        </td>
                        <td>{{ log['added_at'] }}</td>
                    </tr>
                {% endfor %}
                </tbody>
            </table>
        </div>
    {% endif %}
{% endblock %}