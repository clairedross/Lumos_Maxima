with Ada.Containers.Formal_Vectors;
use type Ada.Containers.Count_Type;

package body Email with SPARK_Mode is

   type Length_Type is range 0 .. Max_Email_Length;

   type Email_Address_Buffer_Type is array (Length_Type range <>) of Character;

   type Email_Address_Var_Type (Len : Length_Type := 20) is record
      Ct : Email_Address_Buffer_Type (1 .. Len);
   end record;

   Email_Model : Number_Set with Ghost;

   package Int_To_String is new
     Ada.Containers.Formal_Vectors
       (Index_Type   => Valid_Email_Id,
        Element_Type => Email_Address_Var_Type);

   Data : Int_To_String.Vector (Max_Num_Emails);
   -- Data holds the map from unique identifiers to the actual emails

   ---------------
   -- Invariant --
   ---------------

   function Invariant return Boolean is
     ((for all I1 in 1 .. Int_To_String.Last_Index (Data) =>
         (for all I2 in 1 .. Int_To_String.Last_Index (Data) =>
            (if I1 /= I2 then
               Int_To_String.Element (Data, I1) /=
               Int_To_String.Element (Data, I2))))
      and then Length (Email_Model.Numbers) =
        Ada.Containers.Count_Type (Int_To_String.Last_Index (Data))
      and then
        (for all I in 1 .. Int_To_String.Last_Index (Data) =>
           Contains (Email_Model, I))
      and then
        (for all I of Email_Model.Numbers =>
           I <= Int_To_String.Last_Index (Data)));

   ------------------
   -- Seen_Numbers --
   ------------------

   function Seen_Numbers return Number_Set is (Email_Model);

   ----------------------
   -- To_Email_Address --
   ----------------------

   procedure To_Email_Id
     (S     : String;
      Email : out Email_Id)
   is
      use Ada.Containers;
      use Int_To_String;
      subtype S_Type is String (1 .. S'Length);
      Copy : constant Email_Address_Buffer_Type :=
        Email_Address_Buffer_Type(S_Type(S));
   begin
      --  First look in Data to see if S was already added.

      for Index in 1 .. Last_Index (Data) loop
         pragma Loop_Invariant
           (for all K in 1 .. Index - 1 => Element (Data, K).Ct /= Copy);
         if Element (Data, Index).Ct = Copy then
            Email := Index;
            return;
         end if;
      end loop;

      --  Otherwise if the limit of emails registered has not been reached,
      --  add S and return the corresponding unique identifier.

      if Length (Data) < Max_Num_Emails then
         Append (Data, (Len => S'Length, Ct => Copy));
         Email := Last_Index (Data);
         Email_Model.Numbers := Add (Email_Model.Numbers, Email);
         pragma Assert (for all I in 1 .. Int_To_String.Last_Index (Data) =>
                          Contains (Email_Model, I));

      --  In the last case, S could not be added.

      else
         Email := No_Email_Id;
      end if;
   end To_Email_Id;

end Email;
