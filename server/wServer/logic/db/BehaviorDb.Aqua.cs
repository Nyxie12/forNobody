#region

using wServer.logic.behaviors;
using wServer.logic.loot;
using wServer.logic.transitions;
using common.resources;
#endregion

namespace wServer.logic
{
    partial class BehaviorDb
    {
        private _ AquaLand = () => Behav()
        .Init("coldDude",
            new State(
                new Follow(1),
                new State("1",
                    new Shoot(10, 1, 0, predictive: 1, coolDown: 200),
                    new TimedTransition(1000, "2")
                ),
                new State("2",
                    new Shoot(10, 3, shootAngle: 10, projectileIndex: 0, coolDown: 200),
                    new TimedTransition(1000, "3")
                    ),
                new State("3",
                     new Shoot(10, 4, shootAngle: 90, projectileIndex: 0, coolDownOffset: 200),
                     new TimedTransition(1000, "1")
                    )
                )

            )
        .Init("Titanium Beast",
            new State(
                new Wander(1),
                new ScaleHP(35000, 0),
                new Follow(1),
                new State("Start",
                    new Shoot(10, 5, shootAngle: 10, projectileIndex: 0, coolDown: 500),
                    new TimedTransition(15000, "1")
                ),
                new State("1",
                    new Shoot(10, 16, shootAngle: 22.5, projectileIndex: 0, coolDown: 250, predictive: 1),
                    new TimedTransition(10000, "2")
            ),
                new State("2",
                    new ConditionalEffect(ConditionEffectIndex.Invincible),
                    new Shoot(10, 16, shootAngle: 22.5, projectileIndex: 0, coolDown: 100),
                    new HealSelf(coolDown: 1000, amount: 10000),
                    new TimedTransition(5000, "3")
                    ),
                new State("3",
                    new Taunt("Pathetic humans, you really think I will let you get passed me?"),
                    new Taunt("Useless mortals!"),
                    new Shoot(20, 1, projectileIndex: 0, shootAngle:60),
                    new Shoot(20, 1, projectileIndex:0, shootAngle:120),
                    new Shoot(20, 1, projectileIndex: 0, shootAngle: 180),
                    new Shoot(20, 1, projectileIndex: 0, shootAngle: 240),
                    new Shoot(20, 1, projectileIndex: 0, shootAngle: 300),
                    new Shoot(20, 1, projectileIndex: 0, shootAngle: 360)
                    )
                )
            )
        .Init("Bladefoot",
                new State(
                    new State("Floating",
                        new SetAltTexture(1),
                        new Wander(.2),
                        new Shoot(10, 5, 10, 0, coolDown: 2000),
                        new Shoot(10, 1, 10, 1, coolDown: 4000),
                        new ConditionalEffect(ConditionEffectIndex.Invulnerable),
                        new TimedTransition(1000, "2")
                        ),
                    new State("2",
                        new SetAltTexture(2),
                        new StayCloseToSpawn(.1, 3),
                        new ConditionalEffect(ConditionEffectIndex.Invulnerable),
                        new TimedTransition(1000, "3")
                        ),
                    new State("3",
                        new SetAltTexture(1),
                        new StayCloseToSpawn(.1, 0),
                        new TimedTransition(2500, "deactivate")
                        ),
                    new State("deactivate",
                        new SetAltTexture(2),
                        new StayCloseToSpawn(.1, 0),
                        new EntityNotExistsTransition("Ghost Lanturn On", 10, "Floating")
                        )
                    )
            )


        ;

    }
}