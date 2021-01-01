using wServer.networking.packets;
using wServer.networking.packets.incoming;
using System;
using System.Linq;

namespace wServer.networking.handlers
{
    internal class ForgeItemHandler : PacketHandlerBase<ForgeItem>
    {
        public override PacketId ID => PacketId.FORGEITEM;

        protected override void HandlePacket(Client client, ForgeItem packet) {
            Handle(client, packet);
        }

        private const ushort
            Shine = 0xa20,
            AbbyWhip = 0xa1f,
            LSor = 0xa21;

        private void Handle(Client client, ForgeItem packet) {
            var rnd = new Random();
            ushort itemValue = 0x0;

            if (client.Player.Inventory[packet.SorSlot.SlotId].ObjectType != packet.SorSlot.ObjectType
                || client.Player.Inventory[packet.ShardSlot.SlotId].ObjectType != packet.ShardSlot.ObjectType)
                return;

            switch (packet.SorSlot.ObjectType) {
                case LSor:
                    {
                        switch (packet.ShardSlot.ObjectType)
                        {
                            case Shine:
                                itemValue = AbbyWhip;
                                break;
                            default:
                                client.Player.SendError("You can not forge anything with these items.");
                                itemValue = 0x0;
                                break;
                        }

                        if (itemValue == 0x0) return;
                        var item = client.Player.Manager.Resources.GameData.Items[itemValue];
                        var itemStr = string.IsNullOrEmpty(item.DisplayId)
                            ? item.ObjectId
                            : item.DisplayId;

                        client.Player.SendError("You have forged an item: '" + itemStr + "'");
                        client.Player.Inventory[packet.SorSlot.SlotId] = item;
                        client.Player.Inventory[packet.ShardSlot.SlotId] = null;

                        var guildId = client.Account.GuildId;
                        if (guildId > 0)
                        {
                            foreach (var w in client.Manager.Worlds.Values)
                            {
                                foreach (var p in w.Players.Values)
                                {
                                    if (p.Client.Account.GuildId == guildId && p != client.Player)
                                    {
                                        p.SendInfo("<" + client.Player.Name + "> has forged an item: '"
                                                                                        + itemStr + "'");
                                    }
                                }
                            }

                            foreach (var i in client.Player.Owner.Players.Values)
                            {
                                if (i.Client.Account.GuildId != guildId)
                                {
                                    i.SendInfo("<" + client.Player.Name + "> has forged an item: '" + itemStr + "'");
                                }
                            }
                        }
                        break;
                    }
            }
        }
    }
}