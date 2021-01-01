using wServer.realm.worlds;

namespace wServer.realm.setpieces
{
    class QueenRealm : ISetPiece
    {
        public int Size { get { return 50; } }

        public void RenderSetPiece(World world, IntPoint pos)
        {
            var proto = world.Manager.Resources.Worlds["RealmQueen"];
            SetPieces.RenderFromProto(world, pos, proto);
        }
    }
}