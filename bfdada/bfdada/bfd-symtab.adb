-----------------------------------------------------------------------
--  symtab -- BFD Symbol Table types and operations
--  Copyright (C) 2002, 2003 Free Software Foundation, Inc.
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
--  The Bfd package exports the GNU Bfd library found in Binutils
--  and Gdb.  It is not intended to be as complete as the C library
--  but still provide enough methods to read any object or binary,
--  observe its sections, its symbol table.
--
with System;
with Bfd.Internal; use Bfd.Internal;
with Bfd.Sections; use Bfd.Sections;
with Bfd.Thin.Symtab;
package body Bfd.Symtab is

   ----------------------
   --  Symbol function and procedures
   ----------------------

   --  Return the symbol name.
   function Get_Name (Sym : in Symbol) return String is
   begin
      return To_Ada (Bfd.Thin.Symtab.Get_Symbol_Name (Sym));
   end Get_Name;

   --  Return the section where the symbol is defined.
   function Get_Section (Sym : in Symbol) return Section is
   begin
      return Current (Bfd.Thin.Symtab.Get_Symbol_Section (Sym));
   end Get_Section;

   --  Returns true if the symbol is local.
   function Is_Local_Label (File : in File_Type;
                            Sym  : in Symbol) return Boolean is
   begin
      return Bfd.Thin.Symtab.Is_Local (File.Abfd, Sym);
   end Is_Local_Label;

   --  Returns true if the label is local.
   function Is_Local_Label_Name (File : in File_Type;
                                 Name : in String) return Boolean is

   begin
      --  return Is_Local (File.Abfd, Name & ASCII.NUL);
      return False;
   end Is_Local_Label_Name;

   ----------------------
   --  Symbol table iterator
   ----------------------

   --  Return true if we are at end of the iterator.
   function Is_Done (It : Symbol_Iterator) return Boolean is
   begin
      return It.Pos >= It.Symtab.Size;
   end Is_Done;

   --  Move the iterator to the next element.
   procedure Next (It : in out Symbol_Iterator) is
   begin
      It.Pos := It.Pos + 1;
   end Next;

   --  Return the current symbol pointed to by the iterator.
   function Current (It : in Symbol_Iterator) return Symbol is
   begin
      return Get_Symbol (It.Symtab, It.Pos);
   end Current;

   --  Return an iterator which allows scanning the symbol table.
   function Get_Iterator (Symbols : in Symbol_Table) return Symbol_Iterator is
      It : Symbol_Iterator;
   begin
      It.Symtab := Symbols;
      It.Pos := 1;
      return It;
   end Get_Iterator;

   ----------------------
   --  Symbol table operations
   ----------------------

   --  Open and read all the symbols.
   --  The symbol table must be closed to avoid leaks.
   procedure Open_Symbols (File : in File_Type;
                           Symbols : out Symbol_Table) is

      Cnt : aliased Integer
        := Bfd.Thin.Symtab.Get_Symtab_Upper_Bound (File.Abfd);
      S : Symbol_Table;

      subtype Symbol_Array_Type is Symbol_Array (1 .. Positive (Cnt));

      Syms : Symbol_Array_Access := new Symbol_Array_Type;
   begin
      Bfd.Thin.Symtab.Read_Symbols (File.Abfd, Cnt'Address,
                                    Syms (1)'Address);
      if Cnt < 0 then
         raise OPEN_ERROR;
      end if;
      S.Size := Natural (Cnt);
      S.Syms := Syms;
      Symbols := S;
   end Open_Symbols;

   --  Close the symbol table and free any resource allocated for it.
   procedure Close_Symbols (Symbols : in out Symbol_Table) is
   begin
      null;
   end Close_Symbols;

   --  Set the symbol table associated with the BFD file.
   procedure Set_Symbols (File : in File_Type;
                          Symbols : in out Symbol_Table) is
   begin
      null;
   end Set_Symbols;

   procedure Find_Nearest_Line (File : in File_Type;
                                Sec : in Section;
                                Symbols : in Symbol_Table;
                                Addr : Vma_Type;
                                Name : out Unbounded_String;
                                Func : out Unbounded_String;
                                Line : out Natural) is

      File_Name : aliased Ptr := System.Null_Address;
      Func_Name : aliased Ptr := System.Null_Address;
      L : aliased Integer := -1;

   begin
      Bfd.Thin.Symtab.Find_Nearest_Line (File.Abfd, Sec.Opaque,
                                         Symbols.Syms (1)'Address, Addr,
                                         File_Name'Address,
                                         Func_Name'Address,
                                         L'Address);
      if L < 0 then
         raise NOT_FOUND;
      end if;

      Line := Natural (L);
      Name := To_Unbounded_String (To_Ada (File_Name));
      Func := To_Unbounded_String (To_Ada (Func_Name));
   end Find_Nearest_Line;

   function Get_Symbol (Symbols : in Symbol_Table;
                        Pos : in Positive) return Symbol is
   begin
      return Symbols.Syms (Pos);
   end Get_Symbol;

   function Get_Symbol (Symbols : in Symbol_Table;
                        Name : in String) return Symbol is
      S : Symbol := Null_Address;
   begin
      return S;
   end Get_Symbol;

   function Get_Size (Symbols : in Symbol_Table) return Natural is
   begin
      return Symbols.Size;
   end Get_Size;

end Bfd.Symtab;