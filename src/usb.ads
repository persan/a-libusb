pragma Ada_2005;
pragma Style_Checks (Off);
with Interfaces.C; use Interfaces.C;
with System;
with Interfaces.C.Strings;

package Usb is
   Version : constant String := "0.1.4";

   CLASS_PER_INTERFACE : constant := 0;
   CLASS_AUDIO         : constant := 1;
   CLASS_COMM          : constant := 2;
   CLASS_HID           : constant := 3;
   CLASS_PRINTER       : constant := 7;
   CLASS_PTP           : constant := 6;
   CLASS_MASS_STORAGE  : constant := 8;
   CLASS_HUB           : constant := 9;
   CLASS_DATA          : constant := 10;
   CLASS_VENDOR_SPEC   : constant := 16#ff#;

   DT_DEVICE           : constant := 16#01#;
   DT_CONFIG           : constant := 16#02#;
   DT_STRING           : constant := 16#03#;
   DT_INTERFACE        : constant := 16#04#;
   DT_ENDPOINT         : constant := 16#05#;

   DT_HID              : constant := 16#21#;
   DT_REPORT           : constant := 16#22#;
   DT_PHYSICAL         : constant := 16#23#;
   DT_HUB              : constant := 16#29#;

   DT_DEVICE_SIZE         : constant := 18;
   DT_CONFIG_SIZE         : constant := 9;
   DT_INTERFACE_SIZE      : constant := 9;
   DT_ENDPOINT_SIZE       : constant := 7;
   DT_ENDPOINT_AUDIO_SIZE : constant := 9;
   DT_HUB_NONVAR_SIZE     : constant := 7;

   MAXENDPOINTS        : constant := 32;

   ENDPOINT_ADDRESS_MASK : constant := 16#0f#;
   ENDPOINT_DIR_MASK     : constant := 16#80#;

   ENDPOINT_TYPE_MASK        : constant := 16#03#;
   ENDPOINT_TYPE_CONTROL     : constant := 0;
   ENDPOINT_TYPE_ISOCHRONOUS : constant := 1;
   ENDPOINT_TYPE_BULK        : constant := 2;
   ENDPOINT_TYPE_INTERRUPT   : constant := 3;

   MAXINTERFACES       : constant := 32;
   MAXALTSETTING       : constant := 128;
   MAXCONFIG           : constant := 8;

   REQ_GET_STATUS      : constant := 16#00#;
   REQ_CLEAR_FEATURE   : constant := 16#01#;

   REQ_SET_FEATURE     : constant := 16#03#;

   REQ_SET_ADDRESS       : constant := 16#05#;
   REQ_GET_DESCRIPTOR    : constant := 16#06#;
   REQ_SET_DESCRIPTOR    : constant := 16#07#;
   REQ_GET_CONFIGURATION : constant := 16#08#;
   REQ_SET_CONFIGURATION : constant := 16#09#;
   REQ_GET_INTERFACE     : constant := 16#0A#;
   REQ_SET_INTERFACE     : constant := 16#0B#;
   REQ_SYNCH_FRAME       : constant := 16#0C#;
   TYPE_STANDARD         : constant := 2#0000_0000#;
   TYPE_CLASS            : constant := 2#0001_0000#;
   TYPE_VENDOR           : constant := 2#0010_0000#;
   TYPE_RESERVED         : constant := 2#0011_0000#;

   RECIP_DEVICE        : constant := 16#00#;
   RECIP_INTERFACE     : constant := 16#01#;
   RECIP_ENDPOINT      : constant := 16#02#;
   RECIP_OTHER         : constant := 16#03#;

   ENDPOINT_IN         : constant := 16#80#;
   ENDPOINT_OUT        : constant := 16#00#;

   ERROR_BEGIN         : constant := 500000;

   LIBUSB_HAS_GET_DRIVER_NP : constant := 1;

   LIBUSB_HAS_DETACH_KERNEL_DRIVER_NP : constant := 1;

   type Descriptor_Header is record
      BLength         : aliased Unsigned_Char;
      BDescriptorType : aliased Unsigned_Char;
   end record;
   pragma Convention (C_Pass_By_Copy, Descriptor_Header);

   type String_Descriptor_WData_Array is array (0 .. 0) of aliased Unsigned_Short;
   type String_Descriptor is record
      BLength         : aliased Unsigned_Char;
      BDescriptorType : aliased Unsigned_Char;
      WData           : aliased String_Descriptor_WData_Array;
   end record;
   pragma Convention (C_Pass_By_Copy, String_Descriptor);

   type Hid_Descriptor is record
      BLength         : aliased Unsigned_Char;
      BDescriptorType : aliased Unsigned_Char;
      BcdHID          : aliased Unsigned_Short;
      BCountryCode    : aliased Unsigned_Char;
      BNumDescriptors : aliased Unsigned_Char;
   end record;
   pragma Convention (C_Pass_By_Copy, Hid_Descriptor);

   type Endpoint_Descriptor is record
      BLength          : aliased Unsigned_Char;
      BDescriptorType  : aliased Unsigned_Char;
      BEndpointAddress : aliased Unsigned_Char;
      BmAttributes     : aliased Unsigned_Char;
      WMaxPacketSize   : aliased Unsigned_Short;
      BInterval        : aliased Unsigned_Char;
      BRefresh         : aliased Unsigned_Char;
      BSynchAddress    : aliased Unsigned_Char;
      Extra            : access Unsigned_Char;
      Extralen         : aliased int;
   end record;
   pragma Convention (C_Pass_By_Copy, Endpoint_Descriptor);

   type Interface_Descriptor is record
      BLength            : aliased Unsigned_Char;
      BDescriptorType    : aliased Unsigned_Char;
      BInterfaceNumber   : aliased Unsigned_Char;
      BAlternateSetting  : aliased Unsigned_Char;
      BNumEndpoints      : aliased Unsigned_Char;
      BInterfaceClass    : aliased Unsigned_Char;
      BInterfaceSubClass : aliased Unsigned_Char;
      BInterfaceProtocol : aliased Unsigned_Char;
      IInterface         : aliased Unsigned_Char;
      Endpoint           : access Endpoint_Descriptor;
      Extra              : access Unsigned_Char;
      Extralen           : aliased int;
   end record;
   pragma Convention (C_Pass_By_Copy, Interface_Descriptor);

   type USB_Interface is record
      Altsetting     : access Interface_Descriptor;
      Num_Altsetting : aliased int;
   end record;
   pragma Convention (C_Pass_By_Copy, USB_Interface);

   type Config_Descriptor is record
      BLength             : aliased Unsigned_Char;
      BDescriptorType     : aliased Unsigned_Char;
      WTotalLength        : aliased Unsigned_Short;
      BNumInterfaces      : aliased Unsigned_Char;
      BConfigurationValue : aliased Unsigned_Char;
      IConfiguration      : aliased Unsigned_Char;
      BmAttributes        : aliased Unsigned_Char;
      MaxPower            : aliased Unsigned_Char;
      C_Interface         : access USB_Interface;
      Extra               : access Unsigned_Char;
      Extralen            : aliased int;
   end record;
   pragma Convention (C_Pass_By_Copy, Config_Descriptor);

   type Device_Descriptor is record
      BLength            : aliased Unsigned_Char;
      BDescriptorType    : aliased Unsigned_Char;
      BcdUSB             : aliased Unsigned_Short;
      BDeviceClass       : aliased Unsigned_Char;
      BDeviceSubClass    : aliased Unsigned_Char;
      BDeviceProtocol    : aliased Unsigned_Char;
      BMaxPacketSize0    : aliased Unsigned_Char;
      IdVendor           : aliased Unsigned_Short;
      IdProduct          : aliased Unsigned_Short;
      BcdDevice          : aliased Unsigned_Short;
      IManufacturer      : aliased Unsigned_Char;
      IProduct           : aliased Unsigned_Char;
      ISerialNumber      : aliased Unsigned_Char;
      BNumConfigurations : aliased Unsigned_Char;
   end record;
   pragma Convention (C_Pass_By_Copy, Device_Descriptor);

   type Ctrl_Setup is record
      BRequestType : aliased Unsigned_Char;
      BRequest     : aliased Unsigned_Char;
      WValue       : aliased Unsigned_Short;
      WIndex       : aliased Unsigned_Short;
      WLength      : aliased Unsigned_Short;
   end record;
   pragma Convention (C_Pass_By_Copy, Ctrl_Setup);

   subtype Filename_Array is Interfaces.C.Char_Array (0 .. 4096);
   type Bus;
   type Device is record
      Next         : access Device;
      Prev         : access Device;
      Filename     : aliased Filename_Array;
      Bus          : access USB.Bus;
      Descriptor   : aliased Device_Descriptor;
      Config       : access Config_Descriptor;
      Dev          : System.Address;
      Devnum       : aliased Unsigned_Char;
      Num_Children : aliased Unsigned_Char;
      Children     : System.Address;
   end record;
   pragma Convention (C_Pass_By_Copy, Device);
   type Device_Access is access all Device;


   type Bus is record
      Next     : access Bus;
      Prev     : access Bus;
      Dirname  : aliased Filename_Array;
      Devices  : access Device;
      Location : aliased Unsigned;
      Root_Dev : access Device;
   end record;
   pragma Convention (C_Pass_By_Copy, Bus);
   type Bus_Access is access all Bus;


   type Dev_Handle is private;

   function Open (Dev : access Device) return Dev_Handle;
   --  Is to be used to open up a device for use.
   --  usb.open must be called before attempting to perform
   --  any operations to the device.
   --  Returns a handle used in future communication with the device.

   function Close (Dev : Dev_Handle) return int;
   procedure Close (Dev : Dev_Handle);
   --  Closes a device opened with usb.open.
   --   No further operations may be performed on the handle
   --  after usb.close is called.
   --  Returns 0 on success or < 0 on error.

   function Get_String
     (Dev    : Dev_Handle;
      Index  : int;
      Langid : int;
      Buf    : access Character;
      Buflen : size_t)
      return int;
   function Get_String
     (Dev    : Dev_Handle;
      Index  : int;
      Langid : int) return String;
   -- retrieves the string descriptor specified by index and langid from a device.
   --  The string will be returned in Unicode as specified by the USB specification.
   --  Returns the number of bytes returned in buf or < 0 on error.

   function Get_String_Simple
     (Dev    : Dev_Handle;
      Index  : int;
      Buf    : access Character;
      Buflen : size_t) return int;
   function Get_String_Simple
     (Dev    : Dev_Handle;
      Index  : int) return String;
   -- Is a wrapper around usb_get_string that retrieves the string description
   --  specified by index in the first language for the descriptor and
   --  converts it into C style ASCII.
   --  Returns number of bytes returned in buf or < 0 on error.

   function Get_Descriptor_By_Endpoint
     (Udev   : Dev_Handle;
      Ep     : int;
      C_Type : Unsigned_Char;
      Index  : Unsigned_Char;
      Buf    : System.Address;
      Size   : int) return int;
   --  retrieves a descriptor from the device identified by the type and index
   --   of the descriptor from the control pipe identified by ep.
   --   Returns number of bytes read for the descriptor or < 0 on error.

   function Get_Descriptor
     (Udev   : Dev_Handle;
      C_Type : Unsigned_Char;
      Index  : Unsigned_Char;
      Buf    : System.Address;
      Size   : int) return int;
   -- Retrieves a descriptor from the device identified by the type and index
   --  of the descriptor from the default control pipe.
   --  Returns number of bytes read for the descriptor or < 0 on error.
   --  See usb_get_descriptor_by_endpoint for a function
   --  that allows the control endpoint to be specified.

   function Bulk_Write
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : System.Address;
      Size    : int;
      Timeout : int) return int;
   function Bulk_Write
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : System.Address;
      Size    : int;
      Timeout : Duration) return int;
   function Bulk_Write
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : String;
      Timeout : Duration) return Natural;
   -- performs a bulk write request to the endpoint specified by ep.
   -- Returns number of bytes written on success or < 0 on erro

   function Bulk_Read
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : System.Address;
      Size    : int;
      Timeout : int) return int;
   function Bulk_Read
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : System.Address;
      Size    : int;
      Timeout : Duration) return int;
   function Bulk_Read
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : String;
      Timeout : Duration) return Natural;
   -- Performs a bulk read request to the endpoint specified by ep.
   --  Returns number of bytes read on success or < 0 on error.


   function Interrupt_Write
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : System.Address;
      Size    : int;
      Timeout : int) return int;
   function Interrupt_Write
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : System.Address;
      Size    : int;
      Timeout : Duration) return int;
   function Interrupt_Write
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : String;
      Timeout : Duration) return Natural;
   -- Performs an interrupt write request to the endpoint specified by ep.
   --  Returns number of bytes written on success or < 0 on error.

   function Interrupt_Read
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : System.Address;
      Size    : int;
      Timeout : int) return int;
   function Interrupt_Read
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : System.Address;
      Size    : int;
      Timeout : Duration) return int;
   function Interrupt_Read
     (Dev     : Dev_Handle;
      Ep      : int;
      Bytes   : String;
      Timeout : Duration) return Natural;
   -- Performs an interrupt read request to the endpoint specified by ep.
   --  Returns number of bytes written on success or < 0 on error.

   function Control_Msg
     (Dev         : Dev_Handle;
      Requesttype : int;
      Request     : int;
      Value       : int;
      Index       : int;
      Bytes       : Interfaces.C.Strings.chars_ptr;
      Size        : int;
      Timeout     : int) return int;
   function Control_Msg
     (Dev         : Dev_Handle;
      Requesttype : int;
      Request     : int;
      Value       : int;
      Index       : int;
      Bytes       : System.Address;
      Size        : int;
      Timeout     : int) return int;
   procedure Control_Msg
     (Dev         : Dev_Handle;
      Requesttype : int;
      Request     : int;
      Value       : int;
      Index       : int;
      Bytes       : System.Address;
      Size        : int;
      Timeout     : int);
   procedure Control_Msg
     (Dev         : Dev_Handle;
      Requesttype : int;
      Request     : int;
      Value       : int;
      Index       : int;
      Bytes       : Interfaces.C.Strings.chars_ptr;
      Size        : int;
      Timeout     : int);
   procedure Control_Msg
     (Dev         : Dev_Handle;
      Requesttype : int;
      Request     : int;
      Value       : int;
      Index       : int;
      Bytes       : String;
      Timeout     : Duration);
   -- performs a control request to the default control pipe on a device.
   --  The parameters mirror the types of the same name in the USB specification.
   --  Returns number of bytes written/read or < 0 on error

   function Set_Configuration (Dev : Dev_Handle; Configuration : int) return int ;
   procedure Set_Configuration (Dev : Dev_Handle; Configuration : int);
   --  Sets the active configuration of a device.
   --   The configuration parameter is the value as specified in the
   --  descriptor field bConfigurationValue.
   --  Returns 0 on success or < 0 on error.

   function Claim_Interface (Dev : Dev_Handle; C_Interface : int) return int ;
   procedure Claim_Interface (Dev : Dev_Handle; Configuration : int);
   --  claims the interface with the Operating System.
   --  The interface parameter is the value as specified in
   --  the descriptor field bInterfaceNumber.
   --  Returns 0 on success or < 0 on error.
   --   code	description
   --  *EBUSY	Interface is not available to be claimed
   --  *ENOMEM	Insufficient memory
   --  Must be called!:
   --  usb-claim_interface must be called before you perform any operations
   --  related to this interface
   --  (like usb_set_altinterface, usb_bulk_write, etc).

   function Release_Interface (Dev : Dev_Handle; C_Interface : int) return int;
   procedure Release_Interface (Dev : Dev_Handle; C_Interface : int);
   --  releases an interface previously claimed with usb_claim_interface.
   --   The interface parameter is the value as specified in the descriptor
   --  field bInterfaceNumber. Returns 0 on success or < 0 on error.

   function Set_Altinterface (Dev : Dev_Handle; Alternate : int) return int;
   procedure Set_Altinterface (Dev : Dev_Handle; Alternate : int);
   --  Sets the active alternate setting of the current interface.
   --  The alternate parameter is the value as specified in the descriptor
   --  field bAlternateSetting.
   --  Returns 0 on success or < 0 on error


   function Clear_Halt (Dev : Dev_Handle; Ep : Unsigned) return int;
   --  clears any halt status on the specified endpoint.
   --  The ep parameter is the value specified in the descriptor field
   --  bEndpointAddress. Returns 0 on success or < 0 on error.

   function Reset (Dev : Dev_Handle) return int;
   --  resets the specified device by sending a RESET down the
   --  port it is connected to.
   --  Returns 0 on success or < 0 on error.
   --  Causes re-enumeration:
   --   After calling usb_reset, the device will need to re-enumerate and thusly,
   --   requires you to find the new device and open a new handle.
   --   The handle used to call usb.reset will no longer work.
   function Get_Driver_Np
     (Dev         : Dev_Handle;
      C_Interface : int;
      Name        : Interfaces.C.Strings.chars_ptr;
      Namelen     : Unsigned)
      return int;
   -- This function will obtain the name of the driver bound to the interface
   --  specified by the parameter interface and place it into the buffer named
   --  name limited to namelen characters.
   --  Returns 0 on success or < 0 on error.
   --  Implemented on Linux only.

   function Detach_Kernel_Driver_Np (Dev : Dev_Handle; C_Interface : int) return int;
   procedure Detach_Kernel_Driver_Np (Dev                : Dev_Handle;
                                      C_Interface        : int;
                                      Ignore_Return_Code : Boolean := False);
   --  This function will detach a kernel driver from the interface
   --   specified by parameter interface.
   --   Applications using libusb can then try claiming the interface.
   --   Returns 0 on success or < 0 on error.
   --   Implemented on Linux only.

   function Strerror return Interfaces.C.Strings.chars_ptr;
   function Strerror return String;


   procedure Set_Debug (Level : int);

   function Find_Busses return int;
   procedure Find_Busses;
   --  will find all of the busses on the system.
   --   Returns the number of changes since previous call to this
   --   function (total of new busses and busses removed).

   function Find_Devices return int;
   procedure Find_Devices;
   --  will find all of the devices on each bus.
   --   This should be called after usb.find_busses.
   --   Returns the number of changes since the previous call to this function
   --   (total of new device and devices removed).

   function Get_Device (Dev : Dev_Handle) return Device_Access;
   function Get_Busses return  Bus_Access;
   -- Returns the value of the global variable usb_busses.


private
   Busses              : access Bus;
   pragma Import (C, Busses, "usb_busses");
   pragma Linker_Options ("-lusb");
   type Dev_Handle is access System.Address;
   procedure Init;

end Usb;
