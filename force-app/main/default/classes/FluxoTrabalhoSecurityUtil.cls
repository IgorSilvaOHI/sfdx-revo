public class FluxoTrabalhoSecurityUtil {
    private static Map<Id, UserRole> UserRoles = null;
    private static Map<Id, List<User>> User4Roles = null;
    
    public static Map<Id, Set<Id>> checkOwnerShip(Set<Id> GroupIds) { 
        
        if (UserRoles == null) {
            UserRoles = new Map<Id, UserRole>([Select Id, Name, ParentRoleId, PortalType From UserRole]);
            User4Roles = SObjectSelectorUtil.BreakById([Select Id, UserRoleId From User Where IsActive = true], 'UserRoleId');
        }
        
        Map<Id, Group> Groups = new Map<Id, Group>([SELECT Id, Type, RelatedId FROM Group Where Id IN :GroupIds ]);
        Map<Id, GroupMember> GroupMembers = new Map<Id, GroupMember>([SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHere GroupId IN :GroupIds]);
        
        Map<Id, Set<Id>> mapa = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> nextGroups = new Map<Id, Set<Id>>();
        Set<Id> cmbGroups = new Set<Id>();
        
        for (GroupMember gm : GroupMembers.values()) {
            if (!mapa.Containskey(gm.GroupId)) mapa.put(gm.GroupId, new Set<Id>());
            
            Set<Id> lista = mapa.get(gm.GroupId);
            
            if (Schema.User.SObjectType == gm.UserOrGroupId.getSobjectType())
            	lista.add(gm.UserOrGroupId);
            else {
                if (!nextGroups.Containskey(gm.GroupId)) nextGroups.put(gm.GroupId, new Set<Id>());
                Set<Id> lst = nextGroups.get(gm.GroupId);
                lst.add(gm.UserOrGroupId);
                cmbGroups.add(gm.UserOrGroupId);
            }
        }
        
        if (!nextGroups.IsEmpty()) {
            Map<Id, Set<Id>> lvlMapa = checkOwnerShip(cmbGroups);
            
            for (Id k : nextGroups.keyset()) { // Grupos deste nível
                Set<Id> lista = mapa.get(k); // Mapa deste nível
                for (Id l : nextGroups.get(k)) { // Grupos do Proximo nível
                    if (!lvlMapa.Containskey(l)) continue;
                    for (Id y : lvlMapa.get(l)) { // Usuários Proximo nível
                        lista.add(y);
                    }
                }
            }
        }
        
        For (Group gp : Groups.values()) {
            if (!mapa.Containskey(gp.Id)) mapa.put(gp.Id, new Set<Id>());
            Set<Id> lista = mapa.get(gp.Id);

            if (gp.Type == 'Role') {
                if (User4Roles.ContainsKey(gp.RelatedId)) {
                    lista.addAll(SObjectSelectorUtil.ExtractIds(User4Roles.get(gp.RelatedId), 'Id'));
                }
            }
            
            if (gp.Type == 'RoleAndSubordinates') {
                lista.addAll(getAllRoles(new Set<Id> { gp.RelatedId }, true));
            }
            
            if (gp.Type == 'RoleAndSubordinatesInternal') {
                lista.addAll(getAllRoles(new Set<Id> { gp.RelatedId }, false));
            }
        }
        
        return mapa;
    }

    private static List<Id> getAllRoles(Set<Id> ParentRoleIds, Boolean open4Portal) { 

        List<Id> users = new List<Id>();
        Set<Id> lvlRoles = new Set<Id>();
        
        for (UserRole ur : UserRoles.values()) {
            if (!ParentRoleIds.Contains(ur.ParentRoleId)) continue;
            if (ur.PortalType == 'Partner' && !open4Portal) continue;
            
            if (User4Roles.ContainsKey(ur.Id)) {
                users.addAll(SObjectSelectorUtil.ExtractIds(User4Roles.get(ur.Id), 'Id'));
            }
            
            lvlRoles.add(ur.Id);
        }
        
        if (!lvlRoles.IsEmpty()) users.addAll(getAllRoles(lvlRoles, open4Portal));

		return users;        
    }
}