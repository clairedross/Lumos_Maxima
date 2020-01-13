with Ada.Containers.Indefinite_Doubly_Linked_Lists;

package Util is

   package String_Lists is new
     Ada.Containers.Indefinite_Doubly_Linked_Lists (String);

   function Extract_Email (Key : String) return String_Lists.List;
end Util;
