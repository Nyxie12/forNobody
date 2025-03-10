﻿using common.resources;
using wServer.logic.behaviors;
using wServer.logic.loot;
using wServer.logic.transitions;


namespace wServer.logic
{
    partial class BehaviorDb
    {
        private _ OryxCastle = () => Behav()
            .Init("Oryx Stone Guardian Right",
                new State(
                    new ScaleHP(20000, 0),
                    new State("Idle",
                        new ConditionalEffect(ConditionEffectIndex.Invulnerable, true),
                        new PlayerWithinTransition(2, "Order")
                    ),
                    new State("Order",
                        new Order(10, "Oryx Stone Guardian Left", "Start"),
                        new TimedTransition(0, "Start")
                    ),
                    new State("Start",
                        new ConditionalEffect(ConditionEffectIndex.Invulnerable),
                        new Flash(0xC0C0C0, 0.5, 3),
                        new TimedTransition(1500, "Together is better")
                    ),
                    new State("Together is better",
                        new State("Lets go",
                            new TimedTransition(10000, "Circle"),
                            new State("Imma Follow",
                                new Follow(1, 2, 0.3),
                                new Shoot(5, 5, shootAngle: 5, coolDown: 1000),
                                new TimedTransition(5000, "Imma chill")
                            ),
                            new State("Imma chill",
                                new Prioritize(
                                    new StayCloseToSpawn(0.5, 3),
                                    new Wander(0.5)
                                ),
                                new Shoot(0, 10, projectileIndex: 2, fixedAngle: 0, coolDown: 1000),
                                new TimedTransition(5000, "Imma Follow")
                            )
                        ),
                        new State("Circle",
                            new State("Prepare",
                                new MoveTo(speed: 1, x: 127.5f, y: 39.5f),
                                new EntityExistsTransition("Oryx Stone Guardian Left", 1, "Prepare2")
                            ),
                            new State("Prepare2",
                                new MoveTo(speed: 1,  x: 130.5f, y: 39.5f),
                                new TimedTransition(1000, "PrepareEnd")
                            ),
                            new State("PrepareEnd",
                                new Orbit(1, 5, target: "Oryx Guardian TaskMaster"),
                                new State("cpe_1",
                                    new Shoot(0, 2, fixedAngle: 0, projectileIndex: 1),
                                    new TimedTransition(200, "cpe_2")
                                ),
                                new State("cpe_2",
                                    new Shoot(0, 2, fixedAngle: 36, projectileIndex: 1),
                                    new TimedTransition(200, "cpe_3")
                                ),
                                new State("cpe_3",
                                    new Shoot(0, 2, fixedAngle: 72, projectileIndex: 1),
                                    new TimedTransition(200, "cpe_4")
                                ),
                                new State("cpe_4",
                                    new Shoot(0, 2, fixedAngle: 108, projectileIndex: 1),
                                    new TimedTransition(200, "cpe_5")
                                ),
                                new State("cpe_5",
                                    new Shoot(0, 2, fixedAngle: 144, projectileIndex: 1),
                                    new TimedTransition(200, "cpe_6")
                                ),
                                new State("cpe_6",
                                    new Shoot(0, 2, fixedAngle: 180, projectileIndex: 1),
                                    new TimedTransition(200, "cpe_7")
                                ),
                                new State("cpe_7",
                                    new Shoot(0, 2, fixedAngle: 216, projectileIndex: 1),
                                    new TimedTransition(200, "cpe_8")
                                ),
                                new State("cpe_8",
                                    new Shoot(0, 2, fixedAngle: 252, projectileIndex: 1),
                                    new TimedTransition(200, "cpe_9")
                                ),
                                new State("cpe_9",
                                    new Shoot(0, 2, fixedAngle: 288, projectileIndex: 1),
                                    new TimedTransition(200, "cpe_10")
                                ),
                                new State("cpe_10",
                                    new Shoot(0, 2, fixedAngle: 324, projectileIndex: 1),
                                    new TimedTransition(200, "checkEntities")
                                ),
                                new State("checkEntities",
                                    new PlayerWithinTransition(3, "cpe_Imma Follow"),
                                    new NoPlayerWithinTransition(3, "cpe_Imma chill")
                                ),
                                new State("cpe_x",
                                    new TimedTransition(5000, "Move Sideways"),
                                    new State("cpe_Imma Follow",
                                        new Follow(1, 3, 0.3),
                                        new Shoot(5, 5, coolDown: 1000),
                                        new TimedTransition(2500, "cpe_Imma chill")
                                    ),
                                    new State("cpe_Imma chill",
                                        new Prioritize(
                                            new StayCloseToSpawn(0.5, 3),
                                            new Wander(0.5)
                                        ),
                                        new Shoot(0, 10, projectileIndex: 2, fixedAngle: 0, coolDown: 1000),
                                        new TimedTransition(2500, "cpe_Imma Follow")
                                    )
                                )
                            )
                        ),
                        new State("Move Sideways",
                            new State("msw_prepare",
                                new MoveTo2(speed: 1, X: 9f, Y: 9f),
                                new TimedTransition(1500, "msw_shoot")
                            ),
                            new State("msw_shoot",
                                new Wander(0.3),
                                new StayCloseToSpawn(0.3),
                                new Shoot(0, 2, fixedAngle: 90.5, coolDown: 250, rotateAngle: 5.5),
                                new Shoot(0, 2, fixedAngle: 4.5, coolDown: 250, rotateAngle: 5.5)
                            )
                        )
                    )
                ),
                new Threshold(0.1,
                    new ItemLoot("Ancient Stone Sword", 0.01),
                    new ItemLoot("Potion of Defense", 1),
                    //new ItemLoot("Gauntlet Chaos", 0.001),
                    new TierLoot(8, ItemType.Weapon, 0.1),
                    new TierLoot(7, ItemType.Armor, 0.1),
                    new TierLoot(3, ItemType.Ring, 0.1)
                )

            )
            .Init("Oryx Stone Guardian Left",
                new State(
                    new ScaleHP(20000, 0),
                    new State("Idle",
                        new ConditionalEffect(ConditionEffectIndex.Invulnerable, true),
                        new PlayerWithinTransition(2, "Order")
                    ),
                    new State("Order",
                        new Order(10, "Oryx Stone Guardian Right", "Start"),
                        new TimedTransition(0, "Start")
                    ),
                    new State("Start",
                        new ConditionalEffect(ConditionEffectIndex.Invulnerable),
                        new Flash(0xC0C0C0, 0.5, 3),
                        new TimedTransition(1500, "Together is better")
                    ),
                    new State("Together is better",
                        new State("Lets go",
                            new TimedTransition(10000, "Circle"),
                            new State("Imma Follow",
                                new Follow(1, 2, 0.3),
                                new Shoot(5, 5, shootAngle: 5, coolDown: 1000),
                                new TimedTransition(5000, "Imma chill")
                            ),
                            new State("Imma chill",
                                new Prioritize(
                                    new StayCloseToSpawn(0.5, 3),
                                    new Wander(0.5)
                                ),
                                new Shoot(0, 10, projectileIndex: 2, fixedAngle: 0, coolDown: 1000),
                                new TimedTransition(5000, "Imma Follow")
                            )
                        ),
                        new State("Circle",
                            new State("Prepare",
                                new MoveTo(speed: 1, x: 127.5f, y: 39.5f),
                                new EntityExistsTransition("Oryx Stone Guardian Right", 1, "Prepare2")
                            ),
                            new State("Prepare2",
                                new MoveTo(speed: 1, x: 124.5f, y: 39.5f),
                                new TimedTransition(1000, "PrepareEnd")
                            ),
                            new State("PrepareEnd",
                                new Orbit(1, 5, target: "Oryx Guardian TaskMaster"),
                                new State("cpe_1",
                                    new Shoot(0, 2, fixedAngle: 0, projectileIndex: 1),
                                    new TimedTransition(200, "cpe_2")
                                ),
                                new State("cpe_2",
                                    new Shoot(0, 2, fixedAngle: 36, projectileIndex: 1),
                                    new TimedTransition(200, "cpe_3")
                                ),
                                new State("cpe_3",
                                    new Shoot(0, 2, fixedAngle: 72, projectileIndex: 1),
                                    new TimedTransition(200, "cpe_4")
                                ),
                                new State("cpe_4",
                                    new Shoot(0, 2, fixedAngle: 108, projectileIndex: 1),
                                    new TimedTransition(200, "cpe_5")
                                ),
                                new State("cpe_5",
                                    new Shoot(0, 2, fixedAngle: 144, projectileIndex: 1),
                                    new TimedTransition(200, "cpe_6")
                                ),
                                new State("cpe_6",
                                    new Shoot(0, 2, fixedAngle: 180, projectileIndex: 1),
                                    new TimedTransition(200, "cpe_7")
                                ),
                                new State("cpe_7",
                                    new Shoot(0, 2, fixedAngle: 216, projectileIndex: 1),
                                    new TimedTransition(200, "cpe_8")
                                ),
                                new State("cpe_8",
                                    new Shoot(0, 2, fixedAngle: 252, projectileIndex: 1),
                                    new TimedTransition(200, "cpe_9")
                                ),
                                new State("cpe_9",
                                    new Shoot(0, 2, fixedAngle: 288, projectileIndex: 1),
                                    new TimedTransition(200, "cpe_10")
                                ),
                                new State("cpe_10",
                                    new Shoot(0, 2, fixedAngle: 324, projectileIndex: 1),
                                    new TimedTransition(200, "checkEntities")
                                ),
                                new State("checkEntities",
                                    new PlayerWithinTransition(3, "cpe_Imma Follow"),
                                    new NoPlayerWithinTransition(3, "cpe_Imma chill")
                                ),
                                new State("cpe_x",
                                    new TimedTransition(5000, "Move Sideways"),
                                    new State("cpe_Imma Follow",
                                        new Follow(1, 3, 0.3),
                                        new Shoot(5, 5, coolDown: 1000),
                                        new TimedTransition(2500, "cpe_Imma chill")
                                    ),
                                    new State("cpe_Imma chill",
                                        new Prioritize(
                                            new StayCloseToSpawn(0.5, 3),
                                            new Wander(0.5)
                                        ),
                                        new Shoot(0, 10, projectileIndex: 2, fixedAngle: 0, coolDown: 1000),
                                        new TimedTransition(2500, "cpe_Imma Follow")
                                    )
                                )
                            )
                        ),
                        new State("Move Sideways",
                            new State("msw_prepare",
                                new MoveTo2(speed: 1, X: -9f, Y: 9f),
                                new TimedTransition(1500, "msw_shoot")
                            ),
                            new State("msw_shoot",
                                new Wander(0.3),
                                new StayCloseToSpawn(0.3),
                                new Shoot(0, 2, fixedAngle: 90.5, coolDown: 250, rotateAngle: 5.5),
                                new Shoot(0, 2, fixedAngle: 4.5, coolDown: 250, rotateAngle: 5.5)
                            )
                        )
                    )
                ),
                 new Threshold(0.1,
                    new ItemLoot("Ancient Stone Sword", 0.01),
                    //new ItemLoot("Gauntlet Mayhem", 0.001),
                    new ItemLoot("Potion of Defense", 1),
                    new TierLoot(8, ItemType.Weapon, 0.1),
                    new TierLoot(7, ItemType.Armor, 0.1),
                    new TierLoot(3, ItemType.Ring, 0.1)
                )
            )
            .Init("Oryx Guardian TaskMaster",
                new State(
                    new ConditionalEffect(ConditionEffectIndex.Invincible, true),
                    new State("Idle",
                        new EntitiesNotExistsTransition(100, "Death", "Oryx Stone Guardian Right", "Oryx Stone Guardian Left")
                    ),
                    new State("Death",
                        new Spawn("Oryx's Chamber Portal", 1, 1),
                        new Suicide()
                    )
                )
            )
            .Init("Oryx's Living Floor",
                new State(
                    new State("Idle",
                        new PlayerWithinTransition(20, "Toss")
                    ),
                    new State("Toss",
                        new TossObject("Quiet Bomb", 10, coolDown: new Cooldown(1000, 500)),
                        new TimedTransition(1500, "Shoot and Toss")
                    ),
                    new State("Shoot and Toss",
                        new NoPlayerWithinTransition(21, "Idle"),
                        new NoPlayerWithinTransition(6, "Toss"),
                        new Shoot(0, 18, fixedAngle: 0, coolDown: new Cooldown(1000, 500)),
                        new TossObject("Quiet Bomb", 10, coolDown: new Cooldown(1000, 500))
                    )
                )
            )
            .Init("Oryx Knight",
                new State(
                      new State("waiting for u bae <3",
                          new PlayerWithinTransition(10, "tim 4 rekkings")
                          ),
                      new State("tim 4 rekkings",
                          new Prioritize(
                              new Wander(0.2),
                              new Follow(0.6, 10, 3, -1, 0)
                             ),
                          new Shoot(10, 3, 20, 0, coolDown: 750),
                          new TimedTransition(5000, "tim 4 singular rekt")
                          ),
                      new State("tim 4 singular rekt",
                          new Prioritize(
                                 new Wander(0.2),
                              new Follow(0.7, 10, 3, -1, 0)
                              ),
                          new Shoot(10, 1, projectileIndex: 0, coolDown: 500),
                          new Shoot(10, 1, projectileIndex: 1, coolDown: 1100),
                          new Shoot(10, 1, projectileIndex: 2, coolDown: 650),
                          new TimedTransition(2500, "tim 4 rekkings")
                         )
                  )
            )
            .Init("Oryx Pet",
                new State(
                      new State("swagoo baboon",
                          new PlayerWithinTransition(10, "anuspiddle")
                          ),
                      new State("anuspiddle",
                          new Prioritize(
                              new Wander(0.2),
                              new Follow(0.6, 10, 0, -1, 0)
                              ),
                          new Shoot(10, 2, shootAngle: 20, projectileIndex: 0, coolDown: 800),
                        new Shoot(10, 1, projectileIndex: 0, coolDown: 500)
                         )
                  )
            )
            .Init("Oryx Insect Commander",
                new State(
                      new State("lol jordan is a nub",
                          new Prioritize(
                              new Wander(0.2)
                              ),
                          new Reproduce("Oryx Insect Minion", 10, 20, 1),
                          new Shoot(10, 1, projectileIndex: 0, coolDown: 1200)
                         )
                  )
            )
            .Init("Oryx Insect Minion",
                new State(
                      new State("its SWARMING time",
                          new Prioritize(
                              new Wander(0.2),
                              new StayCloseToSpawn(0.4, 8),
                                 new Follow(0.8, 10, 1, -1, 0)
                              ),
                          new Shoot(10, 5, projectileIndex: 0, coolDown: 1900),
                          new Shoot(10, 1, projectileIndex: 0, coolDown: 800)
                          )
                  )
            )
            .Init("Oryx Suit of Armor",
                new State(
                      new State("idle",
                          new PlayerWithinTransition(8, "attack me pl0x")
                          ),
                      new State("attack me pl0x",
                          new DamageTakenTransition(1, "jordan is stanking")
                          ),
                      new State("jordan is stanking",
                          new Prioritize(
                               new Wander(0.2),
                               new Follow(0.4, 10, 2, -1, 0)
                              ),
                          new SetAltTexture(1),
                          new Shoot(10, 2, 15, 0, coolDown: 600),
                          new HpLessTransition(0.2, "heal")
                          ),
                      new State("heal",
                          new ConditionalEffect(ConditionEffectIndex.Invulnerable),
                          new SetAltTexture(0),
                          new Shoot(10, 6, projectileIndex: 0, coolDown: 200),
                          new HealSelf(coolDown: 400, amount: 200),
                          new TimedTransition(1600, "jordan is stanking2")
                         ),
                      new State("jordan is stanking2",
                          new Prioritize(
                               new Wander(0.2),
                               new Follow(0.4, 10, 2, -1, 0)
                              ),
                          new SetAltTexture(1),
                          new Shoot(10, 2, 15, 0, coolDown: 600)
                          )
                  )
            )
            .Init("Oryx Eye Warrior",
                new State(
                    new State("swaggin",
                        new PlayerWithinTransition(10, "penispiddle")
                        ),
                    new State("penispiddle",
                              new Follow(0.6, 10),
                          new Shoot(10, 5, projectileIndex: 0, coolDown: 1300),
                          new Shoot(10, 1, projectileIndex: 1, coolDown: 700)
                         )
                  )
            )
            .Init("Oryx Brute",
                new State(
                      new State("swaggin",
                          new PlayerWithinTransition(10, "piddle")
                        ),
                      new State("piddle",
                          new Prioritize(
                              new Wander(0.2),
                              new Follow(0.4, 10, 1, -1, 0)
                              ),
                          new Shoot(10, 5, projectileIndex: 1, coolDown: 1000),
                          new Reproduce("Oryx Eye Warrior", 10, 4, 2),
                          new TimedTransition(5000, "charge")
                          ),
                      new State("charge",
                          new Prioritize(
                              new Wander(0.3),
                              new Follow(1.2, 10)
                              ),
                          new Shoot(10, 5, projectileIndex: 1, coolDown: 1102),
                          new Shoot(10, 5, projectileIndex: 2, coolDown: 821),
                          new Reproduce("Oryx Eye Warrior", 10, 4, 2),
                          new Shoot(10, 3, 10, projectileIndex: 0, coolDown: 444),
                          new TimedTransition(4000, "piddle")
                         )
                  )
            )
            .Init("Quiet Bomb",
                new State(
                    new ConditionalEffect(ConditionEffectIndex.Invincible, true),
                    new State("Idle",
                        new State("Tex1",
                            new TimedTransition(250, "Tex2")
                        ),
                        new State("Tex2",
                            new SetAltTexture(1),
                            new TimedTransition(250, "Tex3")
                        ),
                        new State("Tex3",
                            new SetAltTexture(0),
                            new TimedTransition(250, "Tex4")
                        ),
                        new State("Tex4",
                            new SetAltTexture(1),
                            new TimedTransition(250, "Explode")
                        )
                    ),
                    new State("Explode",
                        new SetAltTexture(0),
                        new Shoot(0, 16, fixedAngle: 0),
                        new Suicide()
                    )
                )
            );
    }
}