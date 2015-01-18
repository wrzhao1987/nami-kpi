{% extends "templates/base.volt" %}
{% block extra_js %}
    {{ javascript_include("/js/dt/jquery.dataTables.min.js") }}
    {{ javascript_include("/js/dt/dataTables.jqueryui.js") }}
    <script language="JavaScript">
        $(function() {
            $("fieldset input button").addClass('ui-widget-content ui-corner-all');
            $("#sub_btn").button();
            $("#user").autocomplete({
                source: function(request, response) {
                    $.ajax({
                        url: "/ajax/username",
                        dataType: "json",
                        data: {
                            term: request.term,
                            srv_id: $("#srv_id").val()
                        },
                        success: function (data) {
                            response( $.ui.autocomplete.filter(data, extractLast(request.term)));
                        }
                    });
                },
                minLength: 1,
                delay: 300,
                focus: function () {
                    return false;
                },
                select: function( event, ui ) {
                    this.value = ui.item.value;
                }
            });
            $("#tabs").tabs();
            $(".d_table").dataTable();
            $('.edit_confirm').dialog({
                autoOpen: false,
                buttons: {
                    "我确认！": function() {
                        var id_field = $("#edit_id");
                        var srv_field = $("#edit_srv");
                        var type_field = $("#forbidden_type");
                        var action = $("#action").val();
                        $.ajax({
                            dataType: "json",
                            type: "post",
                            url: "/info/" + action,
                            data: 'id=' + id_field.val() + '&srv_id=' + srv_field.val() + '&forbidden_type=' + type_field.val(),
                            success: function(data) {
                                if (data.code !== 0) {
                                    alert(data.msg);
                                    return false;
                                } else {
                                    id_field.removeAttr('value');
                                    srv_field.removeAttr('value');
                                    $("#" + action).hide();
                                    $("#un" + action).show();
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
            $(".edit").button();
        });
        function split( val ) {
            return val.split( /,\s*/ );
        }
        function extractLast( term ) {
            return split( term ).pop();
        }
        function edit_confirm(forbid_id, srv_id, action, forbidden_type)
        {
            $("#edit_id").val(forbid_id);
            $("#edit_srv").val(srv_id);
            $("#action").val(action);
            $("#forbidden_type").val(forbidden_type);
            $("#" + action).dialog("open");
        }
    </script>
{% endblock %}
{% block extra_css %}
    <style type="text/css">
        .t_label {background-color: deepskyblue;}
    </style>
    {{ stylesheet_link("/css/dt/dataTables.jqueryui.css") }}
{% endblock %}
{% block content %}
{% if notice['code'] != 403 and uid > 0 %}
    <div class="ui-layout-pane" style="margin-top:100px;">
    {{ form('/info/overview', 'method':'post', 'id':'myform', 'name':'myform') }}
        <fieldset>
            <table style="margin: 0 auto; width: 100%;" border="1">
                <tr>
                    <td colspan="2">
                        <label>请选择服务器:</label>
                        {{ select_static("srv_id", srv_list) }}
                    </td>
                    <td colspan="2">
                        <label>请选择用户:</label>
                        {{ text_field("user", "size": 50) }}
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
    <div id="tabs">
        <ul>
            <li><a href="#tabs-1">基本信息</a></li>
            <li><a href="#tabs-2">卡组</a></li>
            <li><a href="#tabs-3">龙珠</a></li>
            <li><a href="#tabs-4">装备</a></li>
            <li><a href="#tabs-5">道具</a></li>
            <li><a href="#tabs-6">英雄魂魄</a></li>
            <li><a href="#tabs-7">龙珠碎片</a></li>
            <li><a href="#tabs-8">装备碎片</a></li>
            <li><a href="#tabs-50">操作</a></li>
        </ul>
        <div id="tabs-1">
            {% if user_info is defined %}
                <table border="1" style="width: 100%; text-align: center;">
                    <tr>
                        <td class="t_label">UID</td>
                        <td>{{ uid }}</td>
                        <td class="t_label">服务器编号</td>
                        <td>{{ srv_id }}</td>
                        <td class="t_label">用户昵称</td>
                        <td>{{ user_info['name'] }}</td>
                        <td class="t_label">战队等级</td>
                        <td>{{ user_info['level'] }}</td>
                    </tr>
                    <tr>
                        <td class="t_label">用户经验</td>
                        <td>{{ user_info['exp'] }}</td>
                        <td class="t_label">索尼币数量</td>
                        <td>{{ user_info['coin'] }}</td>
                        <td class="t_label">钻石数量</td>
                        <td>{{ user_info['gold'] }}</td>
                        <td class="t_label">荣誉点数</td>
                        <td>{{ user_info['honor'] }}</td>
                    </tr>
                    <tr>
                        <td class="t_label">VIP等级</td>
                        <td>{{ user_info['vip'] }}</td>
                        <td class="t_label">最大通关小节</td>
                        <td>{{ user_info['section'] }}</td>
                        <td class="t_label">新手引导步骤</td>
                        <td>{{ user_info['newbie'] }}</td>
                        <td class="t_label">充值钻石数量</td>
                        <td>{{ user_info['charge'] }}</td>
                    </tr>
                    <tr>
                        <td class="t_label">体力</td>
                        <td>{{ user_info['mission_energy'] }}</td>
                        <td class="t_label">元力</td>
                        <td>{{ user_info['rob_energy'] }}</td>
                        <td class="t_label">上次登录时间</td>
                        <td>{{ user_info['last_login'] }}</td>
                    </tr>
                </table>
            {% endif %}
        </div>
        <div id="tabs-2">
            {% if deck is defined %}
            <table border="1" style="width: 100%; text-align: center;" class="d_table">
                <thead>
                    <th>卡组位置</th>
                    <th>主键ID</th>
                    <th>卡片ID</th>
                    <th>经验</th>
                    <th>等级</th>
                    <th>阶级</th>
                    <th>攻击力</th>
                    <th>防御力</th>
                    <th>生命值</th>
                    <th>技能1等级</th>
                    <th>技能2等级</th>
                    <th>技能3等级</th>
                    <th>技能4等级</th>
                    <th>PVE位置</th>
                    <th>PVP位置</th>
                    <th>龙珠</th>
                    <th>装备</th>
                </thead>
                <tbody>
                {% for pos, detail in deck %}
                    <tr>
                        <td>{{ pos }}</td>
                        {% if detail['card'] != 0 %}
                            <td>{{ detail['card']['id'] }}</td>
                            <td>{{ items[3][detail['card']['card_id']] }}</td>
                            <td>{{ detail['card']['exp'] }}</td>
                            <td>{{ detail['card']['level'] }}</td>
                            <td>{{ detail['card']['phase'] }}</td>
                            <td>{{ detail['card']['atk'] }}</td>
                            <td>{{ detail['card']['def'] }}</td>
                            <td>{{ detail['card']['hp'] }}</td>
                            <td>{{ detail['card']['slevel_1'] }}</td>
                            <td>{{ detail['card']['slevel_2'] }}</td>
                            <td>{{ detail['card']['slevel_3'] }}</td>
                            <td>{{ detail['card']['slevel_4'] }}</td>
                        {% else %}
                            <td></td><td></td><td></td><td></td>
                            <td></td><td></td><td></td><td></td>
                            <td></td><td></td><td></td><td></td>
                        {% endif %}
                        <td>{{ detail['pvepos'] }}</td>
                        <td>{{ detail['pvppos'] }}</td>
                        <td>{{ detail['pvppos'] }}</td>
                        <td>{{ detail['pvppos'] }}</td>
                    </tr>
                {% endfor %}
                </tbody>
            </table>
            {% endif %}
        </div>
        <div id="tabs-3">
            {% if dballs is defined %}
            <table border="1" style="width: 100%; text-align: center;" class="d_table">
                <thead>
                <th>ID</th>
                <th>类型</th>
                <th>等级</th>
                <th>经验</th>
                </thead>
                <tbody>
                {% for id, detail in dballs %}
                    <tr>
                        <td>{{ id }}</td>
                        <td>{{ items[4][detail['dragon_ball_id']] }}</td>
                        <td>{{ detail['level'] }}</td>
                        <td>{{ detail['exp'] }}</td>
                    </tr>
                {% endfor %}
                </tbody>
                </table>
            {% endif %}
        </div>
        <div id="tabs-4">
            {% if equips is defined %}
                <table border="1" style="width: 100%; text-align: center;" class="d_table">
                    <thead>
                    <th>ID</th>
                    <th>名称</th>
                    <th>等级</th>
                    </thead>
                    <tbody>
                    {% for id, detail in equips %}
                        <tr>
                            <td>{{ id }}</td>
                            <td>{{ items[5][detail['equip_id']] }}</td>
                            <td>{{ detail['level'] }}</td>
                        </tr>
                    {% endfor %}
                    </tbody>
                </table>
            {% endif %}
        </div>
        <div id="tabs-6">
            {% if souls is defined %}
                <table border="1" style="width: 100%; text-align: center;" class="d_table">
                    <thead>
                    <th>英雄</th>
                    <th>数量</th>
                    </thead>
                    <tbody>
                    {% for card_id, count in souls %}
                        <tr>
                            <td>{{ items[3][card_id] }}</td>
                            <td>{{ count }}</td>
                        </tr>
                    {% endfor %}
                    </tbody>
                </table>
            {% endif %}
        </div>
        <div id="tabs-7">
            {% if dpieces is defined %}
                <table border="1" style="width: 100%; text-align: center;" class="d_table">
                    <thead>
                    <th>龙珠</th>
                    <th>编号</th>
                    <th>数量</th>
                    </thead>
                    <tbody>
                    {% for id, count in dpieces %}
                        {% set piece_id = id % 6 %}
                        {% set dball_id = (id - piece_id) / 6 + 1 %}
                        <tr>
                            <td>{{ items[4][dball_id] }}</td>
                            <td>{{ piece_id + 1 }}</td>
                            <td>{{ count }}</td>
                        </tr>
                    {% endfor %}
                    </tbody>
                </table>
            {% endif %}
        </div>
        <div id="tabs-8">
            {% if epieces is defined %}
                <table border="1" style="width: 100%; text-align: center;" class="d_table">
                    <thead>
                    <th>装备</th>
                    <th>数量</th>
                    </thead>
                    <tbody>
                    {% for equip_id, count in epieces %}
                        <tr>
                            <td>{{ items[5][equip_id] }}</td>
                            <td>{{ count }}</td>
                        </tr>
                    {% endfor %}
                    </tbody>
                </table>
            {% endif %}
        </div>
        <div id="tabs-50">
            <button class="edit" onclick="edit_confirm({{ uid }}, '{{ srv_id }}', 'forbid', 'user');">封号</button>
            <button class="edit" onclick="edit_confirm({{ uid }}, '{{ srv_id }}', 'unforbid', 'user');">解封</button>
        </div>
    </div>
    <input type="hidden" id="edit_id" name="edit_id" />
    <input type="hidden" id="edit_srv" name="edit_srv" />
    <input type="hidden" id="action" name="action" />
    <input type="hidden" id="forbidden_type" name="forbidden_type" />
    <div class="edit_confirm" id="forbid" title="封禁玩家">
        <p>确定要封禁UID为aa{{ uid }}的玩家吗？</p>
    </div>
    <div class="edit_confirm" id="unforbid" title="解封玩家">
        <p>确定要解封UID为{{ uid }}的玩家吗？</p>
    </div>
{% endif %}
{% endblock %}
