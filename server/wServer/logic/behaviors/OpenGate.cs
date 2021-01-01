using System;
using wServer.realm;
using wServer.realm.entities;

namespace wServer.logic.behaviors
{
    public class OpenGate : Behavior
    {
        private int xMin;
        private int xMax;
        private int yMin;
        private int yMax;

        private string target;
        private int area;

        private bool usearea;

        public OpenGate(int xMin, int xMax, int yMin, int yMax)
        {
            this.xMin = xMin;
            this.xMax = xMax;
            this.yMin = yMin;
            this.yMax = yMax;
        }

        public OpenGate(string target, int area = 10)
        {
            this.target = target;
            this.area = area;
            this.usearea = true;
        }

        protected override void TickCore(Entity host, RealmTime time, ref object state)
        {
            if (usearea)
            {
                for (int x = (int)host.X - area; x <= (int)host.X + area; x++)
                {
                    for (int y = (int)host.Y - area; y <= (int)host.Y + area; y++)
                    {
                        var tile = host.Owner.Map[x, y];
                        if (tile.ObjType == host.Manager.Resources.GameData.IdToObjectType[target])
                        {
                            tile.ObjType = 0;
                            host.Owner.Map[x, y] = tile;
                        }
                    }
                }
            }
            else
            {
                for (int x = xMax; x <= xMax; x++)
                {
                    for (int y = yMin; y <= yMax; y++)
                    {
                        var tile = host.Owner.Map[x, y];
                        tile.ObjType = 0;
                        host.Owner.Map[x, y] = tile;
                    }
                }
            }
        }
    }
}