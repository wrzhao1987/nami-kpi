<div id="menu" class="ui-layout-west ui-layout-pane ui-layout-pane-west">
    <ul id="menu-content">
        {% if role is defined %}
            {% if role != 4 %}
                <li>
                    {{ link_to("javascript:void(0);", "管理员") }}
                    <ul>
                        <li>{{ link_to("/admin/add", "添加管理员") }}</li>
                        <li>-</li>
                        <li>{{ link_to("/admin/modpwd", "修改密码") }}</li>
                        <li>-</li>
                        <li>{{ link_to("/admin/manage", "账号管理") }}</li>
                    </ul>
                </li>
                <li>-</li>
                <li>
                    {{ link_to("javascript:void(0);", "消息推送") }}
                    <ul>
                        <li>{{ link_to("/msg/push", "消息推送") }}</li>
                        <li>-</li>
                        <li>{{ link_to("/msg/record", "推送记录") }}</li>
                    </ul>
                </li>
            {% endif %}
            <li>-</li>
            <li>
                {{ link_to("javascript:void(0);", "公告管理") }}
                <ul>
                    <li>{{ link_to("/announce/add", "发公告") }}</li>
                    <li>-</li>
                    <li>{{ link_to("/announce/manage", "公告记录") }}</li>
                </ul>
            </li>
            <li>-</li>
            <li>
                {{ link_to("javascript:void(0);", "邮件管理") }}
                <ul>
                    <li>{{ link_to("/mail/send", "发送邮件") }}</li>
                    <li>-</li>
                    <li>{{ link_to("/mail/log", "邮件记录") }}</li>
                </ul>
            </li>
            <li>-</li>
            <li>
                {{ link_to("javascript:void(0);", "用户查询") }}
                <ul>
                    <li>{{ link_to("/info/overview", "用户概况") }}</li>
                </ul>
            </li>
            <li>-</li>
            <li>
                {{ link_to("javascript:void(0);", "KPI图表") }}
                <ul>
                    {% if role != 4 %}
                        <li>{{ link_to("/kpi/level", "等级分布") }}</li>
                        <li>-</li>
                    {% endif %}
                    <li>{{ link_to("/kpi/newbie", "新手引导") }}</li>
                    <li>-</li>
                    <li>{{ link_to("/kpi/newUser", "日增新用户") }}</li>
                    <li>-</li>
                    <li>{{ link_to("/kpi/retRate", "留存率") }}</li>
                    <li>-</li>
                    <li>{{ link_to("/kpi/dau", "DAU") }}</li>
                    <li>-</li>
                    {% if role != 4 %}
                        <li>{{ link_to("/kpi/item", "道具产销") }}</li>
                        <li>-</li>
                    {% endif %}
                    {% if role != 4 %}
                        <li>{{ link_to("/kpi/mission", "任务章节") }}</li>
                        <li>-</li>
                    {% endif %}
                    {% if role != 4 %}
                        <li>{{ link_to("/kpi/sysJoin", "参与度") }}</li>
                        <li>-</li>
                    {% endif %}
                    <li>{{ link_to("/kpi/pay", "付费率") }}</li>
                    <li>-</li>
                    {% if role != 4 %}
                        <li>{{ link_to("/kpi/payMap", "付费分布") }}</li>
                    {% endif %}
                </ul>
            </li>
            <li>-</li>
            <li>
                {{ link_to("javascript:void(0);", "兑换码") }}
                <ul>
                    <li>{{ link_to("/exchange/typeList", "模板管理") }}</li>
                    <li>-</li>
                    <li>{{ link_to("/exchange/manageNew", "兑换码管理") }}</li>
                </ul>
            </li>
            <li>-</li>
            <li>
                {{ link_to("javascript:void(0);", "服务器") }}
                <ul>
                    <li>{{ link_to("/server/manage", "服务器管理") }}</li>
                </ul>
            </li>
            <li>-</li>
            <li>
                {{ link_to("javascript:void(0);", "充值") }}
                <ul>
                    <li>{{ link_to("/order/query", "充值查询") }}</li>
                </ul>
            </li>
        {% endif %}
    </ul>
</div>

