// [SGD] RRDC Menu Whiteboard v1.0 - Copyright 2021 Sasha Wyrding (Alex Carpenter) @ Second Life.
// ---------------------------------------------------------------------------------------------------------
// This Source Code Form is subject to the terms of the Mozilla Public License, v2.0. 
//  If a copy of the MPL was not distributed with this file, You can obtain one at 
//  http://mozilla.org/MPL/2.0/.
// =========================================================================================================
integer g_channel;                      // Channel this board is running on.

// tagCheck - Given an avatar key, returns TRUE if they have one of the group tags listed in allowedTags
//             active. Note the prim this script is in must be set to the group that contains the tags.
// ---------------------------------------------------------------------------------------------------------
integer tagCheck(key av)
{
    list allowedTags = ["Red Rock Misc Staff", "Red Rock Trustee"];
    integer found = llListFindList(allowedTags,
        [llList2String(llGetObjectDetails(av, ([OBJECT_GROUP_TAG])), 0)]
    );
    return (llSameGroup(av) && found > -1);
}

// getPresets - Returns a list of up to 9 texture presets for the menu whiteboard.
// ---------------------------------------------------------------------------------------------------------
list getPresets()
{
    list l = [];
    integer i;
    for (i = 0; i < llGetInventoryNumber(INVENTORY_TEXTURE) && llGetListLength(l) < 9; i++)
    {
        string texName = llGetInventoryName(INVENTORY_TEXTURE, i);

        if (llStringLength(texName) <= 20)
        {
            l += [texName];
        }
    }
    return l;
}

default
{
    state_entry()
    {
        llSetMemoryLimit(llGetUsedMemory() + 2048);
        g_channel = -1 * (integer)llFrand(DEBUG_CHANNEL);
        llListen(g_channel, "", "", "");
    }

    touch_start(integer total_number)
    {
        if (tagCheck(llDetectedKey(0))) // Toucher has one of the allowed tags active?
        {
            llDialog(llDetectedKey(0), "\nWhat would you like to do?",
                ["▧ Clear", "✎ Set Custom", "✖ Close"] + getPresets(), g_channel);
        }
        else
        {
            llRegionSayTo(llDetectedKey(0), 0, "Please check that you have the correct group and role activated.");
        }
    }

    listen(integer chan, string name, key id, string mesg)
    {
        if (mesg == "✖ Close")
        {
            return; // Do nothing on close. Same as ignore.
        }
        else if (mesg == "▧ Clear")
        {
            llSetLinkPrimitiveParamsFast(LINK_THIS, [
                PRIM_TEXTURE, 2, "8dcd4a48-2d37-4909-9f78-f7a9eb4ef903",
                <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0
            ]);
            llRegionSayTo(llDetectedKey(0), 0, "Whiteboard cleared.");
        }
        else if (mesg == "✎ Set Custom")
        {
            llTextBox(id, "\nPlease enter the UUID of the texture you wish to apply:", g_channel);
        }
        else if (llListFindList(getPresets(), [mesg]) >= 0) // Preset.
        {
            llSetLinkPrimitiveParamsFast(LINK_THIS, [
                PRIM_TEXTURE, 2, mesg, <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0
            ]);
            llRegionSayTo(llDetectedKey(0), 0, "Set to preset: " + mesg);
        }
        else if ((key)mesg) // Custom.
        {
            llSetLinkPrimitiveParamsFast(LINK_THIS, [
                PRIM_TEXTURE, 2, mesg, <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0
            ]);
            llRegionSayTo(llDetectedKey(0), 0, "Custom texture set.");
        }
    }
}
