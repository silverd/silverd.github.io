---
layout: post
category: ['复习笔记']
title: 静态延迟绑定
---

# 简单复习一下PHP的静态延迟绑定

发现有时候一些知识长久不用就容易生锈，比如“静态延迟绑定”，这个名词现在听上去竟有些陌生，其实这个特性在我们项目早已大量使用了
原理相当于就是在子类继承父类时，会把父类中的 self 关键字全文替换为父类的类名，实现绑定。

所以当我们在子类中调用 self::xxx 时，其实调用的还是父类的成员，要想调用子类自己的，需要使用 static::xxx 关键字

大航海中的代码：

<pre><code class="php">
class Model_Npc_Abstract extends Core_Model_Abstract
{
    public function __construct($npcId)
    {
        if (! $npc = static::read($npcId)) {
            throws(_('指定NPC不存在。') . 'NpcId:' . $npcId);
        }

        $this->_prop  = $npc;
    }
}

class Model_Npc_Regular extends Model_Npc_Abstract
{
    /**
     * 加载 NPC 详情
     *
     * @param $npcId
     * @return array
     */
    public static function read($npcId)
    {
        if (! $npc = Dao('Static_NpcRegular')->get($npcId)) {
            return array();
        }

        return $npc;
    }
}
</code></pre>