{% extends "templates/base.volt" %}
{% block extra_js %}
    {{ javascript_include("/js/dt/jquery.dataTables.min.js") }}
    {{ javascript_include("/js/dt/dataTables.jqueryui.js") }}
    <script language="JavaScript">
        $(function() {
            $('.edit').button();
            $("#sub_btn").button();
            $("#server_radio").buttonset();
            $('#admin-form').dataTable();
            $('#del_confirm').dialog({
                autoOpen: false,
                buttons: {
                    "你就删吧": function() {
                        var id_field = $("#id_to_del");
                        var srv_field = $("#srv_to_del");
                        $.ajax({
                            dataType: "json",
                            type: "post",
                            url: "/announce/del",
                            data: 'id=' + id_field.val() + '&srv_id=' + srv_field.val(),
                            success: function(data) {
                                if (data.code !== 0) {
                                    alert(data.msg);
                                    return false;
                                } else {
                                    $("#post" + $("#id_to_del").val()).hide("highlight");
                                    id_field.removeAttr('value');
                                    srv_field.removeAttr('value');
                                    return true;
                                }
                            }
                        });
                        $( this ).dialog( "close" );
                    },
                    "取消": function() {
                        $(this).dialog("close");
                    }
                }
            });
            {% if srv_id is defined %}
            $("{{ "#server" ~ srv_id }}").prop('checked', true).button('refresh');
            {% endif %}
        });

        function del_confirm(post_id, srv_id)
        {
            $("#id_to_del").val(post_id);
            $("#srv_to_del").val(srv_id);
            $("#del_confirm").dialog("open");
        }
    </script>
{% endblock %}
{% block extra_css %}
    {{ stylesheet_link("/css/dt/dataTables.jqueryui.css") }}
{% endblock %}
{% block content %}
    {% if notice['code'] != 403 %}
    <div class="ui-layout-pane" style="margin-top:100px;">
        {{ form('/announce/manage', 'method':'post', 'id':'myform', 'name':'myform') }}
            <fieldset>
                <label for="server">请选择服务器:</label>
                <div id="server_radio">
                    {% for server_id, server_name in server_list %}
                        <input type="radio" name="server" id="server{{ server_id }}" value="{{ server_id }}" />
                        <label for="server{{ server_id }}">{{ server_name }}</label>
                    {% endfor %}
                </div>
                <br />
                {{ hidden_field(security.getTokenKey(), "value": security.getToken()) }}
                {{ submit_button("查询", "id": "sub_btn", "name": "sub_btn", "class":"ui-widget-content ui-corner-all") }}
            </fieldset>
        {{ end_form() }}
    </div>
        {% if posts is defined %}
        <div class="ui-layout-pane" style="margin-top:100px;">
            <table id="admin-form" class="display" style="text-align: center;">
                <thead>
                    <tr>
                        <th>编号</th>
                        <th>标题</th>
                        <th>正文</th>
                        <th>权重</th>
                        <th>开始时间</th>
                        <th>结束时间</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody>
                {% for post in posts %}
                    <tr id="post{{ post.id }}">
                        <td><label>{{ post.id }}</label></td>
                        <td><label>{{ post.title }}</label></td>
                        <td><label>{{ post.content }}</label></td>
                        <td><label>{{ post.weight }}</label></td>
                        <td><label>{{ post.start }}</label></td>
                        <td><label>{{ post.end }}</label></td>
                        <td>
                            <button class="edit" onclick="del_confirm({{ post.id }}, '{{ srv_id }}');">删除</button>
                            {{ link_to('/announce/edit?id=' ~ post.id ~ '&srv_id=' ~ srv_id, "编辑", "class":"edit") }}
                        </td>
                    </tr>
                {% endfor %}
                </tbody>
            </table>
        </div>
        {% endif %}
    {% endif %}
    <div id="del_confirm" title="删除公告">
        <p>你确定要删除这条记录吗？</p>
        <input type="hidden" id="id_to_del" name="id_to_del" />
        <input type="hidden" id="srv_to_del" name="srv_to_del" />
    </div>
{% endblock %}