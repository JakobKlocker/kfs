
pub const MULTIBOOT_HEADER = 1;

pub const MULTIBOOT_SEARCH                        = 8192;
pub const MULTIBOOT_HEADER_ALIGN                  = 4;

//* The magic field should contain this. */
pub const MULTIBOOT_HEADER_MAGIC                  = 0x1BADB002;

//* This should be in %eax. */
pub const MULTIBOOT_BOOTLOADER_MAGIC              = 0x2BADB002;

//* Alignment of multiboot modules. */
pub const MULTIBOOT_MOD_ALIGN                     = 0x00001000;

//* Alignment of the multiboot info structure. */
pub const MULTIBOOT_INFO_ALIGN                    = 0x00000004;

//* Flags set in the ’flags’ member of the multiboot header. */

//* Align all boot modules on i386 page (4KB) boundaries. */
pub const MULTIBOOT_PAGE_ALIGN                    = 0x00000001;

//* Must pass memory information to OS. */
pub const MULTIBOOT_MEMORY_INFO                   = 0x00000002;

//* Must pass video information to OS. */
pub const MULTIBOOT_VIDEO_MODE                    = 0x00000004;

//* This flag indicates the use of the address fields in the header. */
pub const MULTIBOOT_AOUT_KLUDGE                   = 0x00010000;

//* Flags to be set in the ’flags’ member of the multiboot info structure. */

//* is there basic lower/upper memory information? */
pub const MULTIBOOT_INFO_MEMORY                   = 0x00000001;
//* is there a boot device set? */
pub const MULTIBOOT_INFO_BOOTDEV                  = 0x00000002;
//* is the command-line defined? */
pub const MULTIBOOT_INFO_CMDLINE                  = 0x00000004;
//* are there modules to do something with? */
pub const MULTIBOOT_INFO_MODS                     = 0x00000008;

//* These next two are mutually exclusive */

//* is there a symbol table loaded? */
pub const MULTIBOOT_INFO_AOUT_SYMS                = 0x00000010;
//* is there an ELF section header table? */
pub const MULTIBOOT_INFO_ELF_SHDR                 = 0x00000020;

//* is there a full memory map? */
pub const MULTIBOOT_INFO_MEM_MAP                  = 0x00000040;

//* Is there drive info? */
pub const MULTIBOOT_INFO_DRIVE_INFO               = 0x00000080;

//* Is there a config table? */
pub const MULTIBOOT_INFO_CONFIG_TABLE             = 0x00000100;

//* Is there a boot loader name? */
pub const MULTIBOOT_INFO_BOOT_LOADER_NAME         = 0x00000200;

//* Is there a APM table? */
pub const MULTIBOOT_INFO_APM_TABLE                = 0x00000400;

//* Is there video information? */
pub const MULTIBOOT_INFO_VBE_INFO                 = 0x00000800;
pub const MULTIBOOT_INFO_FRAMEBUFFER_INFO         = 0x00001000;

pub const multiboot_header = extern struct {
  //* Must be MULTIBOOT_MAGIC - see above. */
  magic: u32,

  //* Feature flags. */
  flags: u32,

  //* The above fields plus this one must equal 0 mod 2^32. */
  checksum: u32,

  //* These are only valid if MULTIBOOT_AOUT_KLUDGE is set. */
  header_addr: u32,
  load_addr: u32,
  load_end_addr: u32,
  bss_end_addr: u32,
  entry_addr: u32,

  //* These are only valid if MULTIBOOT_VIDEO_MODE is set. */
  mode_type: u32,
  width: u32,
  height: u32,
  depth: u32,

};


//* The symbol table for a.out. */
pub const multiboot_aout_symbol_table = extern struct {
    tabsize: u32,
    strsize: u32,
    addr: u32,
    reserved: u32,
};
pub const multiboot_aout_symbol_table_t = multiboot_aout_symbol_table;

//* The section header table for ELF. */
pub const multiboot_elf_section_header_table = extern struct {
    num: u32,
    size: u32,
    addr: u32,
    shndx: u32,
};
pub const multiboot_elf_section_header_table_t = multiboot_elf_section_header_table;

pub const MULTIBOOT_FRAMEBUFFER_TYPE_INDEXED = 0;
pub const MULTIBOOT_FRAMEBUFFER_TYPE_RGB     = 1;
pub const MULTIBOOT_FRAMEBUFFER_TYPE_EGA_TEXT     = 2;
pub const multiboot_info = extern struct  {
    //* Multiboot info version number */
    flags: u32,

    //* Available memory from BIOS */
    mem_lower: u32,
    mem_upper: u32,

    //* "root" partition */
    boot_device: u32,

    //* Kernel command line */
    cmdline: u32,

    //* Boot-Module list */
    mods_count: u32,
    mods_addr: u32,

    u: extern union {
        aout_sym: multiboot_aout_symbol_table_t,
        elf_sec: multiboot_elf_section_header_table_t,
    },

    //* Memory Mapping buffer */
    mmap_length: u32,
    mmap_addr: u32,

    //* Drive Info buffer */
    drives_length: u32,
    drives_addr: u32,

    //* ROM configuration table */
    config_table: u32,

    //* Boot Loader Name */
    boot_loader_name: u32,

    //* APM table */
    apm_table: u32,

    //* Video */
    vbe_control_info: u32,
    vbe_mode_info: u32,
    vbe_mode: u16,
    vbe_interface_seg: u16,
    vbe_interface_off: u16,
    vbe_interface_len: u16,

    framebuffer_addr: u64,
    framebuffer_pitch: u32,
    framebuffer_width: u32,
    framebuffer_height: u32,
    framebuffer_bpp: u8,
    framebuffer_type: u8,
    colors: extern union {
        pallets: extern struct {
            framebuffer_palette_addr: u32,
            framebuffer_palette_num_colors: u16,
        },
        masks: extern struct {
            framebuffer_red_field_position: u8,
            framebuffer_red_mask_size: u8,
            framebuffer_green_field_position: u8,
            framebuffer_green_mask_size: u8,
            framebuffer_blue_field_position: u8,
            framebuffer_blue_mask_size: u8,
        },
    },
};
pub const multiboot_info_t = multiboot_info;

pub const multiboot_color = extern struct {
    red: u8,
    green: u8,
    blue: u8,
};

pub const MULTIBOOT_MEMORY_AVAILABLE              = 1;
pub const MULTIBOOT_MEMORY_RESERVED               = 2;
pub const MULTIBOOT_MEMORY_ACPI_RECLAIMABLE       = 3;
pub const MULTIBOOT_MEMORY_NVS                    = 4;
pub const MULTIBOOT_MEMORY_BADRAM                 = 5;
pub const multiboot_mmap_entry = packed struct {
    size: u32,
    addr: u64,
    len: u64,
    type: u32,
};
pub const multiboot_memory_map_t = multiboot_mmap_entry;

pub const multiboot_mod_list = extern struct {
    //* the memory used goes from bytes ’mod_start’ to ’mod_end-1’ inclusive */
    mod_start: u32,
    mod_end: u32,

    //* Module command line */
    cmdline: u32,

    //* padding to take it to 16 bytes (must be zero) */
    pad: u32,
};
pub const multiboot_module_t = multiboot_mod_list;

//* APM BIOS info. */
pub const multiboot_apm_info = extern struct {
    version: u16,
    cseg: u16,
    offset: u32,
    cseg_16: u16,
    dseg: u16,
    flags: u16,
    cseg_len: u16,
    cseg_16_len: u16,
    dseg_len: u16,
};
