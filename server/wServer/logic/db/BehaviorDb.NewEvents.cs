using common.resources;
using wServer.logic.behaviors;
using wServer.logic.loot;
using wServer.logic.transitions;

namespace wServer.logic
{
    partial class BehaviorDb
    {
        private _ RandomEvents = () => Behav()
            .Init("murky slimey",
            new State(
                new Prioritize(
                    new Follow(1)
                    ),
                new Shoot(10, 4, shootAngle: 10, coolDown: 750),
                new Grenade(5, damage: 100, range: 6, effect:ConditionEffectIndex.Slowed),
                new Taunt("You'll never be able to kill my father!")
            ));
    }
}
