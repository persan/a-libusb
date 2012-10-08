with GNAT.Source_Info;
package body Usb is

   function Image (I : int) return String is
      Ret : constant String := I'Img;
   begin
      if Ret (Ret'First) = ' ' then
         return "[" & Ret (Ret'First + 1 .. Ret'Last) & "]";
      else
         return "[" & Ret & "] ";
      end if;
   end;
   ----------
   -- Open --
   ----------

   function Open (Dev : access Device) return Dev_Handle is
      function Usb_Open (Dev : access Device) return Dev_Handle;  -- /usr/include/usb.h:287
      pragma Import (C, Usb_Open, "usb_open");

   begin
      return Ret : constant Dev_Handle := Usb_Open (Dev) do
         if Ret = null then
            raise Program_Error with "Unable to open device";
         end if;
      end return;
   end Open;

   -----------
   -- Close --
   -----------

   function Close (Dev : Dev_Handle) return int is
      function Usb_Close (Dev : Dev_Handle) return int;  -- /usr/include/usb.h:288
      pragma Import (C, Usb_Close, "usb_close");
   begin
      return Usb_Close (Dev);
   end Close;

   -----------
   -- Close --
   -----------

   procedure Close (Dev : Dev_Handle) is
      Ret      : int;
   begin
      Ret := Close (Dev);
      if Ret < 0 then
         raise Program_Error with "Unable to close interface";
      end if;
   end Close;

   ----------------
   -- Get_String --
   ----------------

   function Get_String
     (Dev    : Dev_Handle;
      Index  : int;
      Langid : int;
      Buf    : access Character;
      Buflen : size_t)
      return int
   is
      function Usb_Get_String
        (Dev    : Dev_Handle;
         Index  : int;
         Langid : int;
         Buf    : access Character;
         Buflen : size_t) return int;  -- /usr/include/usb.h:289
      pragma Import (C, Usb_Get_String, "usb_get_string");

   begin
      return Usb_Get_String (Dev, Index, Langid, Buf, Buflen);
   end Get_String;
   function Get_String
     (Dev    : Dev_Handle;
      Index  : int;
      Langid : int) return String is
      Buf  : array (1 .. 1024) of aliased Character;
      Last : int;
   begin
      Last := Get_String (Dev, Index, Langid, Buf (Buf'First)'Access, Buf'Length);
      return String (Buf (1 .. Integer (Last)));
   end;

   -----------------------
   -- Get_String_Simple --
   -----------------------

   function Get_String_Simple
     (Dev    : Dev_Handle;
      Index  : int;
      Buf    : access Character;
      Buflen : size_t)
      return int
   is
      function Usb_Get_String_Simple
        (Dev    : Dev_Handle;
         Index  : int;
         Buf    : access Character;
         Buflen : size_t)
         return int;
      pragma Import (C, Usb_Get_String_Simple, "usb_get_string_simple");

   begin
      return Usb_Get_String_Simple (Dev, Index, Buf, Buflen);
   end Get_String_Simple;

   function Get_String_Simple
     (Dev    : Dev_Handle;
      Index  : int) return String is
      Buf  : array (1 .. 1024) of aliased Character;
      Last : int;
   begin
      Last := Get_String_Simple (Dev, Index,  Buf (Buf'First)'Access, Buf'Length);
      return String (Buf (1 .. Integer (Last	)));
   end;
   --------------------------------
   -- Get_Descriptor_By_Endpoint --
   --------------------------------

   function Get_Descriptor_By_Endpoint
     (Udev   : Dev_Handle;
      Ep     : int;
      C_Type : Unsigned_Char;
      Index  : Unsigned_Char;
      Buf    : System.Address;
      Size   : int) return int
   is
      function Usb_Get_Descriptor_By_Endpoint
        (Udev   : Dev_Handle;
         Ep     : int;
         C_Type : Unsigned_Char;
         Index  : Unsigned_Char;
         Buf    : System.Address;
         Size   : int) return int;
      pragma Import (C, Usb_Get_Descriptor_By_Endpoint, "usb_get_descriptor_by_endpoint");

   begin
      return Usb_Get_Descriptor_By_Endpoint (Udev, Ep, C_Type, Index, Buf, Size);
   end Get_Descriptor_By_Endpoint;

   --------------------
   -- Get_Descriptor --
   --------------------

   function Get_Descriptor
     (Udev   : Dev_Handle;
      C_Type : Unsigned_Char;
      Index  : Unsigned_Char;
      Buf    : System.Address;
      Size   : int) return int
   is
      function Usb_Get_Descriptor
        (Udev   : Dev_Handle;
         C_Type : Unsigned_Char;
         Index  : Unsigned_Char;
         Buf    : System.Address;
         Size   : int) return int;
      pragma Import (C, Usb_Get_Descriptor, "usb_get_descriptor");

   begin
      return Usb_Get_Descriptor (Udev, C_Type, Index, Buf, Size);
   end Get_Descriptor;

   ----------------
   -- Bulk_Write --
   ----------------

   function Bulk_Write
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : System.Address;
      Size    : int;
      Timeout : int)
      return int
   is
      function Usb_Bulk_Write
        (Dev     : Dev_Handle;
         Ep      : int;
         Bytes   : System.Address;
         Size    : int;
         Timeout : int)
         return int;
      pragma Import (C, Usb_Bulk_Write, "usb_bulk_write");

   begin
      return Usb_Bulk_Write (Dev, Ep, Bytes, Size, Timeout);
   end Bulk_Write;
   function Bulk_Write
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : System.Address;
      Size    : int;
      Timeout : Duration) return int is
   begin
      return Bulk_Write (Dev, Ep, Bytes, Size, int (Timeout * 1000.0));
   end;

   function Bulk_Write
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : String;
      Timeout : Duration) return Natural is
   begin
      return Natural (Bulk_Write (Dev, Ep, Bytes (Bytes'First)'Address, Bytes'Length, Timeout));
   end;

   ---------------
   -- Bulk_Read --
   ---------------
   function Bulk_Read
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : System.Address;
      Size    : int;
      Timeout : int)
      return int
   is
      function Usb_Bulk_Read
        (Dev     : Dev_Handle;
         Ep      : int;
         Bytes   : System.Address;
         Size    : int;
         Timeout : int)
         return int;
      pragma Import (C, Usb_Bulk_Read, "usb_bulk_read");
   begin
      return USB_Bulk_Read (Dev, Ep, Bytes, Size, Timeout);
   end Bulk_Read;
   function Bulk_Read
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : System.Address;
      Size    : int;
      Timeout : Duration) return int is
   begin
      return Bulk_Read (Dev, Ep, Bytes, Size, int (Timeout * 1000.0));
   end;

   function Bulk_Read
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : String;
      Timeout : Duration) return Natural is
   begin
      return Natural (Bulk_Read (Dev, Ep, Bytes (Bytes'First)'Address, Bytes'Length, Timeout));
   end;
   ---------------------
   -- Interrupt_Write --
   ---------------------

   function Interrupt_Write
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : System.Address;
      Size    : int;
      Timeout : int)
      return int
   is
      function USB_Interrupt_Write
        (Dev     : Dev_Handle;
         Ep      : int;
         Bytes   : System.Address;
         Size    : int;
         Timeout : int)
         return int;
      pragma Import (C, Usb_Interrupt_Write, "usb_interrupt_write");

   begin
      return USB_Interrupt_Write (Dev, Ep, Bytes, Size, Timeout);
   end Interrupt_Write;
   function Interrupt_Write
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : System.Address;
      Size    : int;
      Timeout : Duration) return int is
   begin
      return Interrupt_Write (Dev, Ep, Bytes, Size, int (Timeout * 1000.0));
   end;

   function Interrupt_Write
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : String;
      Timeout : Duration) return Natural is
   begin
      return Natural (Interrupt_Write (Dev, Ep, Bytes (Bytes'First)'Address, Bytes'Length, Timeout));
   end;

   --------------------
   -- Interrupt_Read --
   --------------------

   function Interrupt_Read
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : System.Address;
      Size    : int;
      Timeout : int)
      return int
   is
      function USB_Interrupt_Read
        (Dev     : Dev_Handle;
         Ep      : int;
         Bytes   : System.Address;
         Size    : int;
         Timeout : int)
         return int;
      pragma Import (C, Usb_Interrupt_Read, "usb_interrupt_read");

   begin
      return USB_Interrupt_Read (Dev, Ep, Bytes, Size, Timeout);
   end Interrupt_Read;

  function Interrupt_Read
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : System.Address;
      Size    : int;
      Timeout : Duration) return int is
   begin
      return Interrupt_Read (Dev, Ep, Bytes, Size, int (Timeout * 1000.0));
   end;

   function Interrupt_Read
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : String;
      Timeout : Duration) return Natural is
   begin
      return Natural (Interrupt_Read (Dev, Ep, Bytes (Bytes'First)'Address, Bytes'Length, Timeout));
   end;

   -----------------
   -- Control_Msg --
   -----------------

   function Control_Msg
     (Dev         : Dev_Handle;
      Requesttype : int;
      Request     : int;
      Value       : int;
      Index       : int;
      Bytes       : Interfaces.C.Strings.chars_ptr;
      Size        : int;
      Timeout     : int)
      return int
   is
      function USB_Control_Msg
        (Dev         : Dev_Handle;
         Requesttype : int;
         Request     : int;
         Value       : int;
         Index       : int;
         Bytes       : Interfaces.C.Strings.chars_ptr;
         Size        : int;
         Timeout     : int)
         return int;
      pragma Import (C, Usb_Control_Msg, "usb_control_msg");

   begin
      return USB_Control_Msg (Dev, Requesttype, Request, Value, Index, Bytes, Size,
                              Timeout);
   end Control_Msg;

   -----------------
   -- Control_Msg --
   -----------------

   function Control_Msg
     (Dev         : Dev_Handle;
      Requesttype : int;
      Request     : int;
      Value       : int;
      Index       : int;
      Bytes       : System.Address;
      Size        : int;
      Timeout     : int)
      return int
   is
      function USB_Control_Msg
        (Dev         : Dev_Handle;
         Requesttype : int;
         Request     : int;
         Value       : int;
         Index       : int;
         Bytes       : System.Address;
         Size        : int;
         Timeout     : int)
         return int;
      pragma Import (C, Usb_Control_Msg, "usb_control_msg");

   begin
      return USB_Control_Msg (Dev, Requesttype, Request, Value, Index, Bytes, Size,
                              Timeout);
   end Control_Msg;
   procedure Control_Msg
     (Dev         : Dev_Handle;
      Requesttype : int;
      Request     : int;
      Value       : int;
      Index       : int;
      Bytes       : System.Address;
      Size        : int;
      Timeout     : int)
   is
      Ret : constant int :=  Control_Msg (Dev, Requesttype, Request, Value, Index, Bytes, Size,
                                          Timeout);

   begin
      if Ret < 0 then
         raise Program_Error;
      end if;
   end Control_Msg;
   -----------------
   -- Control_Msg --
   -----------------

   procedure Control_Msg
     (Dev         : Dev_Handle;
      Requesttype : int;
      Request     : int;
      Value       : int;
      Index       : int;
      Bytes       : Interfaces.C.Strings.chars_ptr;
      Size        : int;
      Timeout     : int)
   is
      Ret : constant int :=  Control_Msg (Dev, Requesttype, Request, Value, Index, Bytes, Size,
                                          Timeout);

   begin
      if Ret /= 0 then
         raise Program_Error;
      end if;
   end Control_Msg;

   procedure Control_Msg
     (Dev         : Dev_Handle;
      Requesttype : int;
      Request     : int;
      Value       : int;
      Index       : int;
      Bytes       : String;
      Timeout     : Duration) is

   begin
      Control_Msg (Dev         => Dev,
                   Requesttype => Requesttype,
                   Request     => Request,
                   Value       => Value,
                   Index       => Index,
                   Bytes       => Bytes'Address,
                   Size        => Bytes'Length,
                   Timeout     => int (Timeout * 1000.0));
   end;

   -----------------------
   -- Set_Configuration --
   -----------------------

   function Set_Configuration
     (Dev           : Dev_Handle;
      Configuration : int)
      return int
   is
      function USB_Set_Configuration
        (Dev           : Dev_Handle;
         Configuration : int)
         return int;
      pragma Import (C, Usb_Set_Configuration, "usb_set_configuration");

   begin
      return USB_Set_Configuration (Dev, Configuration);
   end Set_Configuration;

   -----------------------
   -- Set_Configuration --
   -----------------------

   procedure Set_Configuration (Dev : Dev_Handle; Configuration : int) is
      Ret : constant int :=  Set_Configuration (Dev, Configuration);
   begin
      if Ret /= 0 then
         raise Program_Error;
      end if;
   end Set_Configuration;

   ---------------------
   -- Claim_Interface --
   ---------------------

   function Claim_Interface
     (Dev         : Dev_Handle;
      C_Interface : int)
      return int
   is
      function Usb_Claim_Interface
        (Dev         : Dev_Handle;
         C_Interface : int)
         return int;
      pragma Import (C, Usb_Claim_Interface, "usb_claim_interface");

   begin
      return USB_Claim_Interface (Dev, C_Interface);
   end Claim_Interface;

   ---------------------
   -- Claim_Interface --
   ---------------------

   procedure Claim_Interface (Dev : Dev_Handle; Configuration : int) is
      Ret : constant int :=  Claim_Interface (Dev, Configuration);
   begin
      if Ret /= 0 then
         raise Program_Error;
      end if;
   end Claim_Interface;

   -----------------------
   -- Release_Interface --
   -----------------------

   function Release_Interface
     (Dev         : Dev_Handle;
      C_Interface : int)
      return int
   is
      function USB_Release_Interface
        (Dev         : Dev_Handle;
         C_Interface : int)
         return int;
      pragma Import (C, Usb_Release_Interface, "usb_release_interface");
   begin
      return USB_Release_Interface (Dev, C_Interface);
   end Release_Interface;

   -----------------------
   -- Release_Interface --
   -----------------------

   procedure Release_Interface (Dev : Dev_Handle; C_Interface : int) is
      Ret : constant int :=  Release_Interface (Dev, C_Interface);
   begin
      if Ret /= 0 then
         raise Program_Error;
      end if;
   end Release_Interface;

   ----------------------
   -- Set_Altinterface --
   ----------------------

   function Set_Altinterface (Dev : Dev_Handle; Alternate : int) return int is
      function USB_Set_Altinterface (Dev : Dev_Handle; Alternate : int) return int;
      pragma Import (C, Usb_Set_Altinterface, "usb_set_altinterface");

   begin
      return USB_Set_Altinterface (Dev, Alternate);
   end Set_Altinterface;

   ----------------------
   -- Set_Altinterface --
   ----------------------

   procedure Set_Altinterface (Dev : Dev_Handle; Alternate : int) is
      Ret : constant int :=  Set_Altinterface (Dev, Alternate);
   begin
      if Ret /= 0 then
         raise Program_Error;
      end if;
   end Set_Altinterface;


   ----------------
   -- Clear_Halt --
   ----------------

   function Clear_Halt (Dev : Dev_Handle; Ep : Unsigned) return int is
      function USB_Clear_Halt (Dev : Dev_Handle; Ep : Unsigned) return int;
      pragma Import (C, Usb_Clear_Halt, "usb_clear_halt");
   begin
      return USB_Clear_Halt (Dev, Ep);
   end Clear_Halt;

   -----------
   -- Reset --
   -----------

   function Reset (Dev : Dev_Handle) return int is
      function USB_Reset (Dev : Dev_Handle) return int;
      pragma Import (C, Usb_Reset, "usb_reset");
   begin
      return USB_Reset (Dev);
   end Reset;

   -------------------
   -- Get_Driver_Np --
   -------------------

   function Get_Driver_Np
     (Dev         : Dev_Handle;
      C_Interface : int;
      Name        : Interfaces.C.Strings.chars_ptr;
      Namelen     : Unsigned)
      return int is
      function USB_Get_Driver_Np
        (Dev         : Dev_Handle;
         C_Interface : int;
         Name        : Interfaces.C.Strings.chars_ptr;
         Namelen     : Unsigned)
         return int;
      pragma Import (C, Usb_Get_Driver_Np, "usb_get_driver_np");
   begin
      return USB_Get_Driver_Np (Dev, C_Interface, Name, Namelen);
   end Get_Driver_Np;

   -----------------------------
   -- Detach_Kernel_Driver_Np --
   -----------------------------

   function Detach_Kernel_Driver_Np
     (Dev         : Dev_Handle;
      C_Interface : int)
      return int
   is
      function USB_Detach_Kernel_Driver_Np
        (Dev         : Dev_Handle;
         C_Interface : int)
         return int;
      pragma Import (C, Usb_Detach_Kernel_Driver_Np, "usb_detach_kernel_driver_np");

   begin
      return USB_Detach_Kernel_Driver_Np (Dev, C_Interface);
   end Detach_Kernel_Driver_Np;

   -----------------------------
   -- Detach_Kernel_Driver_Np --
   -----------------------------

   procedure Detach_Kernel_Driver_Np (Dev : Dev_Handle; C_Interface : int; Ignore_Return_Code : Boolean := False) is
      Ret : constant int := Detach_Kernel_Driver_Np (Dev, C_Interface);
   begin
      if not Ignore_Return_Code then
         if Ret /= 0 then
            raise Program_Error with GNAT.Source_Info.Enclosing_Entity & Image (Ret) & " <" & Strerror & ">";
         end if;
      end if;
   end Detach_Kernel_Driver_Np;

   --------------
   -- Strerror --
   --------------

   function Strerror return Interfaces.C.Strings.chars_ptr is
      function USB_Strerror return Interfaces.C.Strings.chars_ptr;
      pragma Import (C, Usb_Strerror, "usb_strerror");

   begin
      return USB_Strerror;
   end Strerror;

   function Strerror return String is
   begin
      return Interfaces.C.Strings.Value (Strerror);
   end Strerror;

   ----------
   -- Init --
   ----------

   procedure Init is
      procedure Usb_Init;  -- /usr/include/usb.h:327
      pragma Import (C, Usb_Init, "usb_init");
   begin
      Usb_Init;
   end Init;

   ---------------
   -- Set_Debug --
   ---------------

   procedure Set_Debug (Level : int) is
      procedure Usb_Set_Debug (Level : int);  -- /usr/include/usb.h:328
      pragma Import (C, Usb_Set_Debug, "usb_set_debug");
   begin
      Usb_Set_Debug (Level);
   end Set_Debug;

   -----------------
   -- Find_Busses --
   -----------------

   function Find_Busses return int is
      function Usb_Find_Busses return int;  -- /usr/include/usb.h:329
      pragma Import (C, Usb_Find_Busses, "usb_find_busses");
   begin
      return USB_Find_Busses;
   end Find_Busses;

   procedure Find_Busses is
      Dummy : constant int := Find_Busses;
      pragma Unreferenced (Dummy);
   begin
      null;
   end Find_Busses;

   ------------------
   -- Find_Devices --
   ------------------

   function Find_Devices return int is
      function Usb_Find_Devices return int;  -- /usr/include/usb.h:330
      pragma Import (C, Usb_Find_Devices, "usb_find_devices");
   begin
      return USB_Find_Devices;
   end Find_Devices;
   procedure Find_Devices is
      Dummy : constant int := Find_Devices;
      pragma Unreferenced (Dummy);
   begin
      null;
   end Find_Devices;

   --------------------
   -- Get_Usb_Device --
   --------------------

   function Get_Device (Dev : Dev_Handle) return  Device_Access is
      function Usb_Device (Dev : Dev_Handle) return Device_Access;
      pragma Import (C, Usb_Device, "usb_device");
   begin
      return Usb_Device (Dev);
   end Get_Device;

   ----------------
   -- Get_Busses --
   ----------------

   function Get_Busses return Bus_Access is
      function Usb_Get_Busses return Bus_Access;  -- /usr/include/usb.h:332
      pragma Import (C, Usb_Get_Busses, "usb_get_busses");
   begin
      return Usb_Get_Busses;
   end Get_Busses;
begin
   Init;
end Usb;
