using System;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using common;
using common.resources;
using TagLib;
using wServer.networking;
using wServer.realm.entities;
using wServer.realm.worlds;
using wServer.realm.worlds.logic;
using System.Collections.Generic;
using wServer.networking.packets;
using wServer.networking.packets.incoming;
using wServer.networking.packets.outgoing;
using File = TagLib.File;
using MarketResult = wServer.realm.entities.MarketResult;

namespace wServer.realm.commands
{
    class HelpCommand : Command
    {
        public HelpCommand() : base("commands") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            StringBuilder sb = new StringBuilder("Server Commands: ");
            var cmds = player.Manager.Commands.Commands.Values.Distinct()
                .Where(x => x.HasPermission(player) && x.ListCommand)
                .ToArray();
            Array.Sort(cmds, (c1, c2) => c1.CommandName.CompareTo(c2.CommandName));
            for (int i = 0; i < cmds.Length; i++)
            {
                if (i != 0) sb.Append(" | ");
                sb.Append(cmds[i].CommandName);
            }

            player.SendInfo(sb.ToString());
            return true;
        }
    }

    class UptimeCommand : Command
    {
        public UptimeCommand() : base("uptime") { }

        protected override bool Process(Player player, RealmTime time, string args)
        {
            TimeSpan t = TimeSpan.FromMilliseconds(time.TotalElapsedMs);

            string answer = string.Format("{0:D2}d:{1:D2}h:{2:D2}m:{3:D2}s:{4:D2}ms",
                            t.Days,
                            t.Hours,
                            t.Minutes,
                            t.Seconds,
                            t.Milliseconds);

            player.SendInfo("The server has been up for " + answer + ".");
            return true;
        }
    }
}
