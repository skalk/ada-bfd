-----------------------------------------------------------------------
--  print -- Print Utilities for examples
--  Copyright (C) 2002, 2003, 2004 Free Software Foundation, Inc.
--  Written by Stephane Carrez (stcarrez@nerim.fr)
--
--  This file is part of BfdAda.
--
--  This program is free software; you can redistribute it and/or
--  modify it under the terms of the GNU General Public License as
--  published by the Free Software Foundation; either version 2,
--  or (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; see the file COPYING.  If not, write to
--  the Free Software Foundation, 59 Temple Place - Suite 330,
--  Boston, MA 02111-1307, USA.
-----------------------------------------------------------------------
with Bfd;
with Bfd.Disassemble; use Bfd.Disassemble;
package Utils is

   procedure Print (Item : in String; Max_Len : in Integer);

   function HexImage (Addr : in Bfd.Vma_Type) return String;

   type Small_Disassembler is new Memory_Disassembler with null record;

   procedure Output (Dis  : in out Small_Disassembler;
                     Item : in String);

end Utils;
