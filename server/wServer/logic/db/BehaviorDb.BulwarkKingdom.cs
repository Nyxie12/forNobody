using wServer.logic.behaviors;
using wServer.logic.loot;
using wServer.logic.transitions;
using common.resources;

namespace wServer.logic
{
    partial class BehaviorDb
    {
        private _ BulwarkKingdom = () => Behav()
        .Init("Bulwark Soldier",
            new State(
                new Wander(0.2),
                new Shoot(15, 1, predictive: 1, coolDown: 400)
                )
            );
    }
}
