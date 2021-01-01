using common.resources;
using wServer.realm.entities;
using wServer.realm;
using System;
using System.Collections.Generic;

namespace wServer.realm.entities
{
    partial class Player
    {
        public bool CheckHpRegenBoost()
        {
            var ok = false;
            for (var i = 0; i < 20; i++)
            {
                var inv = Inventory[i];
                if (inv != null && inv.ObjectId == "Spirit of the Champion" && HP <= Stats[0] / 2)
                    ok = true;
            }
            return ok == true;
        }      
    }
    partial class Player
    {
        public bool CheckatkBoostTali()
        {
            var ok = false;
            for (var i = 0; i < 20; i++)
            {
                var inv = Inventory[i];
                if (inv != null && inv.ObjectId == "Adakima" && Stats[2] >= 0)
                    ok = true;
            }
            return ok == true;
        }
    }
    partial class Player
    {
        public bool CheckspdBoostTali()
        {
            var ok = false;
            for (int i = 0; i < 20; i++)
            {
                var inv = Inventory[i];
                if (inv != null && inv.ObjectId == "Efkinisia" && Stats[4] >= 0)
                    ok = true;
            }
            return ok == true;
        }
    }
    partial class Player
    {
        public bool CheckhpBoostTali()
        {
            var ok = false;
            for (var i = 0; i < 20; i++)
            {
                var inv = Inventory[i];
                if (inv != null && inv.ObjectId == "Ygeia" && Stats[0] >= 0)
                    ok = true;
            }
            return ok == true;
        }
    }

    

}