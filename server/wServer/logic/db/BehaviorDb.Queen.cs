using common.resources;
using wServer.logic.behaviors;
using wServer.logic.loot;
using wServer.logic.transitions;

namespace wServer.logic
{
    partial class BehaviorDb
    {
        private _ Queen = () => Behav()
            .Init("Queen of Hearts",
                new State(
                    new ScaleHP(10000, 0),
                    new State("0",
                        new PlayerWithinTransition(15, "1")
                        ),
                    new State("1",
                        new HpLessTransition(0.85, "2"),
                        //
                        new Taunt("Today is the day you will die! Your journey ends here, hero."),
                        new Shoot(10, 5, 10, 0, predictive: 0.8, coolDown: 1500),
                        new ConditionalEffect(ConditionEffectIndex.AttBoost)
                        ),
                    new State("2",
                        new HpLessTransition(0.5, "3"),
                        //
                        new Spawn("Card Knight Black", 2, 1, 1000, false),
                        new Spawn("Card Knight Red", 2, 1, 1000, false),
                        new Taunt("Henchmen, get ready for this fight, they are true warriors!"),
                        new Shoot(10, 5, 10, 0, predictive: 0.8, coolDown: 1500),
                        new Shoot(10, 5, projectileIndex: 1, fixedAngle: 0, rotateAngle: 15, coolDown: 666),
                        new ConditionalEffect(ConditionEffectIndex.DexBoost)
                        ),
                    new State("3",
                        new HpLessTransition(0.25, "4"),
                        //
                        new Shoot(10, 8, projectileIndex: 3, fixedAngle: 0, rotateAngle: 15, coolDown: 900),
                        new Shoot(10, 5, 10, 2, predictive: 0.8, coolDown: 2000)
                        ),
                    new State("4",
                        new Wander(0.2),
                        //
                        new Spawn("Card Knight Black", 3, 1, 1200, false),
                        new Spawn("Card Knight Red", 3, 1, 1200, false),
                        new Taunt("You shall not succeed!"),
                        new Grenade(3.5, 120, 10, coolDown: 1200, color: 0xff0000),
                        new Shoot(10, 8, projectileIndex: 3, fixedAngle: 0, rotateAngle: 15, coolDown: 900),
                        new Shoot(10, 7, 20, 2, predictive: 0.8, coolDown: 2000)
                        )
                    ),
                new Threshold(0.025,
                    new ItemLoot("QueensHead", 0.045),
                    new ItemLoot("Greater Potion of Vitality", 1.0),
                    new ItemLoot("Greater Potion of Dexterity", 1.0),
                    new TierLoot(11, ItemType.Weapon, 0.05),
                    new TierLoot(5, ItemType.Ability, 0.05),
                    new TierLoot(12, ItemType.Armor, 0.05),
                    new TierLoot(4, ItemType.Ring, 0.05)
                )
            )

            .Init("Card Knight Red",
                new State(
                    new ScaleHP(1000, 0),
                    new Charge(1.25, 10, 800),
                    new Shoot(8, 3, shootAngle: 10, coolDown: 800)
                    ),
                    new ItemLoot("Card Armor", 0.005),
                    new ItemLoot("Health Potion", 0.2)
            )
           .Init("Card Knight Black",
                new State(
                    new ScaleHP(1000, 0),
                    new Orbit(0.7, 1.5, target: "Card Knight Red", orbitClockwise: true, radiusVariance: 0.5),
                    new Shoot(8, 2, shootAngle: 12, coolDown: 1200)
                    ),
                    new ItemLoot("Card Armor", 0.005),
                    new ItemLoot("Magic Potion", 0.2)
            )

            ;
    }
}
