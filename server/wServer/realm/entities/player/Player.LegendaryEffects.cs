using System;
using System.Collections.Generic;
using common.resources;
using StackExchange.Redis;
using wServer.networking.packets.outgoing;
using wServer.realm.worlds.logic;

namespace wServer.realm.entities
{
    partial class Player
    {
        private readonly Position target;

        public bool CheckInventory(string item)
        {
            var Checked = false;
            for (var i = 0; i < 4; i++)
            {
                var inv = Inventory[i];
                if (inv != null && inv.ObjectId == item)
                    Checked = true;
            }
            return Checked;
        }

        #region Effects

        #region Marks
        void RageI(Position target)
        {
            if (Random.NextDouble() < 0.01)
            {
                ApplyConditionEffect(ConditionEffectIndex.Damaging, 250);
                ApplyConditionEffect(ConditionEffectIndex.Berserk, 250);
                BroadcastSync(new Notification()
                {
                    ObjectId = Id,
                    Color = new ARGB(0xFF0000),
                    Message = "Rage x I"
                }, p => this.DistSqr(p) < RadiusSqr);
                BroadcastSync(new ShowEffect()
                {
                    EffectType = EffectType.AreaBlast,
                    TargetObjectId = Id,
                    Color = new ARGB(0xFF0000),
                    Pos1 = new Position() { X = 1 }
                }, p => this.DistSqr(p) < RadiusSqr);
            }
        }

        void RageII(Position target)
        {
            if (Random.NextDouble() < 0.02)
            {
                ApplyConditionEffect(ConditionEffectIndex.Damaging, 350);
                ApplyConditionEffect(ConditionEffectIndex.Berserk, 350);
                BroadcastSync(new Notification()
                {
                    ObjectId = Id,
                    Color = new ARGB(0xFF0000),
                    Message = "Rage x II"
                }, p => this.DistSqr(p) < RadiusSqr);
                BroadcastSync(new ShowEffect()
                {
                    EffectType = EffectType.AreaBlast,
                    TargetObjectId = Id,
                    Color = new ARGB(0xFF0000),
                    Pos1 = new Position() { X = 2 }
                }, p => this.DistSqr(p) < RadiusSqr);
            }
        }

        void RageIII(Position target)
        {
            if (Random.NextDouble() < 0.03)
            {
                ApplyConditionEffect(ConditionEffectIndex.Damaging, 450);
                ApplyConditionEffect(ConditionEffectIndex.Berserk, 450);
                BroadcastSync(new Notification()
                {
                    ObjectId = Id,
                    Color = new ARGB(0xFF0000),
                    Message = "Rage x III"
                }, p => this.DistSqr(p) < RadiusSqr);
                BroadcastSync(new ShowEffect()
                {
                    EffectType = EffectType.AreaBlast,
                    TargetObjectId = Id,
                    Color = new ARGB(0xFF0000),
                    Pos1 = new Position() { X = 3 }
                }, p => this.DistSqr(p) < RadiusSqr);
            }
        }

        void RageIV(Position target)
        {
            if (Random.NextDouble() < 0.04)
            {
                ApplyConditionEffect(ConditionEffectIndex.Damaging, 550);
                ApplyConditionEffect(ConditionEffectIndex.Berserk, 550);
                BroadcastSync(new Notification()
                {
                    ObjectId = Id,
                    Color = new ARGB(0xFF0000),
                    Message = "Rage x IV"
                }, p => this.DistSqr(p) < RadiusSqr);
                BroadcastSync(new ShowEffect()
                {
                    EffectType = EffectType.AreaBlast,
                    TargetObjectId = Id,
                    Color = new ARGB(0xFF0000),
                    Pos1 = new Position() { X = 4 }
                }, p => this.DistSqr(p) < RadiusSqr);
            }
        }
        #endregion

        #region MinorCut
        void MinorCut(Position target)
        {
            if (Random.NextDouble() < 0.007)
            {
                ApplyConditionEffect(ConditionEffectIndex.Bleeding, 2500);
                BroadcastSync(new Notification()
                {
                    ObjectId = Id,
                    Color = new ARGB(0xFF0000),
                    Message = "Minor Cut"
                }, p => this.DistSqr(p) < RadiusSqr);
                BroadcastSync(new ShowEffect()
                {
                    EffectType = EffectType.AreaBlast,
                    TargetObjectId = Id,
                    Color = new ARGB(0xFF0000),
                    Pos1 = new Position() { X = 3 }
                }, p => this.DistSqr(p) < RadiusSqr);
            }
        }
        #endregion

        #region Vigorous
        void Vigorous(Position target)
        {
            if (Random.NextDouble() < 0.02)
            {
                ApplyConditionEffect(ConditionEffectIndex.Damaging, 2000);
                BroadcastSync(new Notification()
                {
                    ObjectId = Id,
                    Color = new ARGB(0xFF0000),
                    Message = "Vigorous"
                }, p => this.DistSqr(p) < RadiusSqr);
                BroadcastSync(new ShowEffect()
                {
                    EffectType = EffectType.AreaBlast,
                    TargetObjectId = Id,
                    Color = new ARGB(0xFF0000),
                    Pos1 = new Position() { X = 3 }
                }, p => this.DistSqr(p) < RadiusSqr);
            }
        }
        #endregion

        #region Juggernaut
        void Juggernaut(Position target)
        {
            if (Random.NextDouble() < 0.03)
            {
                ApplyConditionEffect(ConditionEffectIndex.Armored, 2500);
                BroadcastSync(new Notification()
                {
                    ObjectId = Id,
                    Color = new ARGB(0x4B0082),
                    Message = "Juggernaut"
                }, p => this.DistSqr(p) < RadiusSqr);
                BroadcastSync(new ShowEffect()
                {
                    EffectType = EffectType.AreaBlast,
                    TargetObjectId = Id,
                    Color = new ARGB(0x4B0082),
                    Pos1 = new Position() { X = 3 }
                }, p => this.DistSqr(p) < RadiusSqr);
            }
        }
        #endregion

        #region Blessing
        void Blessing(Position target)
        {
            if (Random.NextDouble() < 0.06)
            {
                ApplyConditionEffect(ConditionEffectIndex.Healing, 3000);
                BroadcastSync(new Notification()
                {
                    ObjectId = Id,
                    Color = new ARGB(0xFFB6C1),
                    Message = "Blessing"
                }, p => this.DistSqr(p) < RadiusSqr);
                BroadcastSync(new ShowEffect()
                {
                    EffectType = EffectType.AreaBlast,
                    TargetObjectId = Id,
                    Color = new ARGB(0xFFB6C1),
                    Pos1 = new Position() { X = 3 }
                }, p => this.DistSqr(p) < RadiusSqr);
            }
        }
        #endregion

        #region Mighty
        void Mighty(Position target)
        {
            if (Random.NextDouble() < 0.02)
            {
                var id = (IsControlling) ? SpectateTarget.Id : Id;

                ApplyConditionEffect(ConditionEffectIndex.Berserk, 3500);
                BroadcastSync(new Notification()
                {
                    ObjectId = Id,
                    Color = new ARGB(0xFF6347),
                    Message = "Mighty"
                }, p => this.DistSqr(p) < RadiusSqr);
                BroadcastSync(new ShowEffect()
                {
                    EffectType = EffectType.AreaBlast,
                    TargetObjectId = Id,
                    Color = new ARGB(0xFF6347),
                    Pos1 = new Position() { X = 3 }
                }, p => this.DistSqr(p) < RadiusSqr);
            }
        }
        #endregion

        #region Crippled
        void Crippled(Position target)
        {
            if (Random.NextDouble() < 0.001)
            {
                ApplyConditionEffect(ConditionEffectIndex.Slowed, 3000);
                BroadcastSync(new Notification()
                {
                    ObjectId = Id,
                    Color = new ARGB(0x4C4646),
                    Message = "Crippled"
                }, p => this.DistSqr(p) < RadiusSqr);
                BroadcastSync(new ShowEffect()
                {
                    EffectType = EffectType.AreaBlast,
                    TargetObjectId = Id,
                    Color = new ARGB(0x4C4646),
                    Pos1 = new Position() { X = 3 }
                }, p => this.DistSqr(p) < RadiusSqr);
            }
        }
        #endregion

        #region Fatigue
        void Fatigue(Position target)
        {
            if (Random.NextDouble() < 0.004)
            {
                    ApplyConditionEffect(ConditionEffectIndex.Weak, 1500);
                    BroadcastSync(new Notification()
                    {
                        ObjectId = Id,
                        Color = new ARGB(0xFFFFFF),
                        Message = "Fatigue"
                    }, p => this.DistSqr(p) < RadiusSqr);
                    BroadcastSync(new ShowEffect()
                    {
                        EffectType = EffectType.AreaBlast,
                        TargetObjectId = Id,
                        Color = new ARGB(0xFFFFFF),
                        Pos1 = new Position() { X = 3 }
                    }, p => this.DistSqr(p) < RadiusSqr);
            }
        }
        #endregion

        #region Almighty
        void Almighty(Position target)
        {
            
            {
                ApplyConditionEffect(ConditionEffectIndex.Healing, 4500);
                ApplyConditionEffect(ConditionEffectIndex.Berserk, 4500);
                ApplyConditionEffect(ConditionEffectIndex.Damaging, 4500);
                BroadcastSync(new Notification()
                {
                    ObjectId = Id,
                    Color = new ARGB(0xFFFF00),
                    Message = "Almighty"
                }, p => this.DistSqr(p) < RadiusSqr);
                BroadcastSync(new ShowEffect()
                {
                    EffectType = EffectType.AreaBlast,
                    TargetObjectId = Id,
                    Color = new ARGB(0xFFFF00),
                    Pos1 = new Position() { X = 3 }
                }, p => this.DistSqr(p) < RadiusSqr);
            }
        }
        #endregion

        #region Reflexes
        void Reflexes(Position target)
        {
            if (Random.NextDouble() < 0.01)
            {
                ApplyConditionEffect(ConditionEffectIndex.Speedy, 3000);
                BroadcastSync(new Notification()
                {
                    ObjectId = Id,
                    Color = new ARGB(0x32CD32),
                    Message = "Reflexes"
                }, p => this.DistSqr(p) < RadiusSqr);
                BroadcastSync(new ShowEffect()
                {
                    EffectType = EffectType.AreaBlast,
                    TargetObjectId = Id,
                    Color = new ARGB(0x32CD32),
                    Pos1 = new Position() { X = 3 }
                }, p => this.DistSqr(p) < RadiusSqr);
            }
        }
        #endregion

        #region Faithful
        void Faithful(Position target)
        {
            if (Random.NextDouble() < 0.01)
            {
                ApplyConditionEffect(ConditionEffectIndex.Damaging, 2250);
                ApplyConditionEffect(ConditionEffectIndex.Speedy, 2250);
                BroadcastSync(new Notification()
                {
                    ObjectId = Id,
                    Color = new ARGB(0x835C3B),
                    Message = "Faithful"
                }, p => this.DistSqr(p) < RadiusSqr);
                BroadcastSync(new ShowEffect()
                {
                    EffectType = EffectType.AreaBlast,
                    TargetObjectId = Id,
                    Color = new ARGB(0x835C3B),
                    Pos1 = new Position() { X = 3 }
                }, p => this.DistSqr(p) < RadiusSqr);
            }
        }
        #endregion

        #region Unstable Pilot
        void Unstable(Position target)
        {
            if (Random.NextDouble() < 0.0008)
            {
                ApplyConditionEffect(ConditionEffectIndex.Unstable, 3300);
                BroadcastSync(new Notification()
                {
                    ObjectId = Id,
                    Color = new ARGB(0xF0F8FF),
                    Message = "Unstable Pilot"
                }, p => this.DistSqr(p) < RadiusSqr);
                BroadcastSync(new ShowEffect()
                {
                    EffectType = EffectType.AreaBlast,
                    TargetObjectId = Id,
                    Color = new ARGB(0xF0F8FF),
                    Pos1 = new Position() { X = 3 }
                }, p => this.DistSqr(p) < RadiusSqr);
            }
        }
        #endregion
        #endregion

        #region items
        void LegendaryEffects(RealmTime time)
        {
            var gameData = Manager.Resources.GameData;

            #region Ignited Inferno Axe
            if (CheckInventory("Ignited Inferno Axe"))
            {
                Almighty(target);
            }
            #endregion

            #region Ascended Shendyt of Geb
            if (CheckInventory("Ascended Shendyt of Geb"))
            {
                Almighty(target);
            }
            #endregion
            #region Ascended Wand of Geb
            if (CheckInventory("Ascended Wand of Geb"))
            {
                Almighty(target);
            }
            #endregion
        }
        #endregion
    }
  }