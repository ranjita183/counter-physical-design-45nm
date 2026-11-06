# ASIC Physical Design of 45nm Up/Down Counter (Netlist-to-GDSII)

![Process Node](https://img.shields.io/badge/Process-45nm%20GSCLIB045-blue)
![Tool](https://img.shields.io/badge/EDA%20Tool-Cadence%20Innovus%2020.14-red)
![Synthesis Engine](https://img.shields.io/badge/Synthesis-Cadence%20Genus%2020.11-orange)
![Clock Frequency](https://img.shields.io/badge/Target%20Frequency-100%20MHz%20(10ns)-green)
![Flow Stage](https://img.shields.io/badge/Flow-Netlist--to--GDSII-purple)

This repository contains the complete **ASIC Physical Design (Place and Route - PnR)** implementation of a **4-bit Up/Down Counter (`up_dn`)** using **Cadence Innovus Implementation System (v20.14)** and a **45nm standard cell PDK (`gsclib045`)**.

The design flow executes all physical design stages from gate-level netlist import, floorplanning, power grid network design (PG Mesh), standard cell placement, Clock Tree Synthesis (CTS via CCOpt), global/detail routing (NanoRoute), DRC/connectivity verification, up to final **GDSII layout stream-out**.

---

## 📌 Design Specifications & PnR Metrics

| Parameter / Feature | Specification Details |
| :--- | :--- |
| **Top-Level Module** | `up_dn` (4-bit counter: `clk`, `rst`, `mode`, `cout[3:0]`) |
| **Technology Node** | 45nm CMOS (`gsclib045` standard cell library, LVT variant) |
| **Synthesis Tool** | Cadence Genus Synthesis Solution (v20.11-s111_1) |
| **PnR EDA Tool** | Cadence Innovus Implementation System (v20.14) |
| **Target Clock Frequency** | **100.00 MHz** (Clock Period: `10.0 ns`, Waveform: `0.0 ns` to `5.0 ns`) |
| **Core Utilization** | **50% – 55%** |
| **Core Aspect Ratio** | `1.0` (Square core geometry) |
| **Core Margins** | `5 µm` on Left, Right, Top, Bottom |
| **Power Grid Network** | Core PG Rings (Metal8/Metal9), Horizontal Stripes (Metal9), Vertical Stripes (Metal8) |
| **Physical Cells** | Checkerboard WellTap cells (`FILL2` @ 45µm pitch), EndCap cells (`FILL2`) |
| **Routing Layers** | Metal1 (Bottom) to Metal7 (Top Routing Layer) |
| **Clock Sinks Insertion Delay** | Target Skew: `0.1 ns`, Target Max Trans: `0.2 ns`, Setup/Hold Uncertainty: `0.1 ns` |
| **Analysis Corners (MMMC)** | **Setup Corner**: `func_ss` (`slow_vdd1v0`) \| **Hold Corner**: `func_ff` (`fast_vdd1v0`/`fast_vdd1v2`) |

---

## 📁 Repository Directory Structure

```
counter-physical-design-45nm/
├── README.md                          # Comprehensive project documentation
├── .gitignore                         # Cadence Innovus log & binary database filter
├── inputs/                            # Design netlist, SDC constraints, and MMMC configs
│   ├── Default.globals                # Innovus global environment & library pointers
│   ├── Default.view                   # MMMC view definitions (Corner setup)
│   ├── counter_netlist.v              # Gate-level Verilog netlist (Cadence Genus output)
│   └── counter_sdc.sdc                # Synopsys Design Constraints (100 MHz clock)
├── scripts/                           # Modular TCL physical design scripts
│   ├── master_flow.tcl                # Master script to run full PnR flow sequentially
│   ├── floorplan_new.tcl              # Floorplanning, pin assignment & physical cells
│   ├── power_plan.tcl                 # VDD/VSS Power rings, stripes, and sroute rails
│   ├── placement.tcl                  # Global/detail placement & pre-CTS timing opt
│   ├── cts.tcl                        # Clock Tree Synthesis (CCOpt), latency & skew opt
│   └── route.tcl                      # NanoRoute global/detail routing & GDSII export
├── images/                            # Innovus GUI snapshots (2D layout, CTD, 3D stack)
│   ├── 01_floorplan_power_grid.png
│   ├── 02_clock_tree_debugger_ctd.png
│   ├── 03_clock_tree_topology.png
│   ├── 04_routed_layout_2d.png
│   └── 05_3d_interconnect_stack.png
└── reports/                           # Quality of Results (QoR) sanity & check reports
    ├── chek_lef.txt                   # Physical LEF library verification report
    ├── netlist_check.txt              # Gate-level netlist connectivity report
    └── pin_check.txt                  # IO pin alignment & overlap check report
```

---

## 🛠️ Step-by-Step Physical Design Flow

### Step 1: Floorplanning & Physical Cell Insertion (`floorplan_new.tcl`)
- Imports the netlist (`counter_netlist.v`), MMMC views (`Default.view`), and technology LEF files (`gsclib045.lef`).
- Initializes core and die area using `floorPlan -r {1 0.5 5 5 5 5}`.
- Constrains input pins (`clk`, `rst`, `mode`) to the **Left side** (Metal5) and output pins (`cout[3:0]`) to the **Right side** (Metal5).
- Inserts **EndCap cells** (`FILL2`) on row edges and **WellTap cells** (`FILL2`) in a checkerboard pattern at a maximum interval of **45 µm**.

### Step 2: Power Planning (`power_plan.tcl`)
- Configures logical power and ground net connections (`globalNetConnect VDD / VSS`).
- Constructs core power rings: **Metal8 (Vertical)** and **Metal9 (Horizontal)** with $1\,\mu\text{m}$ width and spacing.
- Generates power grid mesh:
  - **Horizontal Power Stripes**: Metal9, width $1\,\mu\text{m}$, set-to-set distance $20\,\mu\text{m}$.
  - **Vertical Power Stripes**: Metal8, width $1\,\mu\text{m}$, set-to-set distance $20\,\mu\text{m}$.
- Runs `sroute` to connect standard cell `VDD`/`VSS` power pins to the top-level PG grid.

### Step 3: Standard Cell Placement (`placement.tcl`)
- Restricts routing layers from **Metal1 to Metal7**.
- Sets global placement max density to **70%** (`setPlaceMode -place_global_max_density 0.70`).
- Executes coarse global placement, placement optimization, and legalization (`place_design`, `refinePlace`, `place_opt_design`).
- Analyzes 3D routing congestion (`reportCongestion -3d`) and reports pre-CTS timing (`timeDesign -preCTS`).

### Step 4: Clock Tree Synthesis - CTS (`cts.tcl`)
- Configures CCOpt clock tree buffer pools (`CLKBUFX2LVT` to `CLKBUFX16LVT`) and inverter pools (`CLKINVX2LVT` to `CLKINVX12LVT`).
- Targets: `max_fanout` = 8, `target_max_trans` = 0.2 ns, `target_skew` = 0.1 ns, `target_insertion_delay` = 0.2 ns.
- Runs `clock_opt_design` / `ccopt_design` to build low-skew clock trees.
- Validates latency and skew using `report_clock_timing` and performs post-CTS timing/hold optimization (`optDesign -postCTS -hold`).

### Step 5: Global & Detail Routing (`route.tcl`)
- Configures NanoRoute engine and enables automatic antenna diode insertion (`route_detail_fix_antenna true`).
- Executes global and detailed routing (`routeDesign -globalDetail`).
- Performs DRC checks (`verify_drc`) and connectivity validation (`verifyConnectivity`).
- Fixes open nets and antenna violations via `ecoRoute`.
- Generates post-route timing reports (`timeDesign -postRoute`).
- Streams out final layout GDSII format to `./outputs/final.gds`.

---

## 🖼️ Physical Design Layout Gallery

### 1. Power Grid Network & Floorplan Layout
![Floorplan & Power Grid Mesh](images/01_floorplan_power_grid.png)
*Floorplan core area, VDD/VSS power rings, stripes, IO pin placements, and physical cells (EndCaps & WellTaps).*

---

### 2. Clock Tree Synthesis (CTS) & Clock Tree Debugger (CTD)
| Cadence CCOpt Clock Tree Debugger (CTD) | Clock Tree Topology Hierarchy |
| :---: | :---: |
| ![Clock Tree Debugger](images/02_clock_tree_debugger_ctd.png) | ![Clock Tree Topology](images/03_clock_tree_topology.png) |
| *Clock Tree Sinks Latency & Skew Tree Hierarchy* | *CCOpt Clock Tree Network Buffer & Inverter Topology* |

---

### 3. Routing & Final 2D Layout
![Routed 2D Layout](images/04_routed_layout_2d.png)
*Complete Routed Design showing Metal1–Metal7 Signal Nets, Power Grid, Standard Cell Placement, and IO Pins.*

---

### 4. 3D Interconnect Multi-Layer Stack
![3D Interconnect Stack View](images/05_3d_interconnect_stack.png)
*Cadence Innovus 3D perspective visualization showing multi-layer metal interconnect stack (Metal1 through Metal9), vias, power rails, and standard cell instances.*

---

## 🚀 How to Run the Flow in Cadence Innovus

### Option A: Run the Master Flow (End-to-End Execution)
Launch Cadence Innovus in batch or interactive mode and source the master flow script:
```bash
innovus -files scripts/master_flow.tcl
```

### Option B: Modular Execution (Step-by-Step Execution)
Alternatively, you can run each stage interactively inside the Innovus shell:

```tcl
# 1. Import Design & Floorplan
source ./scripts/floorplan_new.tcl

# 2. Execute Power Planning (Sourced automatically or manually)
source ./scripts/power_plan.tcl

# 3. Standard Cell Placement & Pre-CTS Optimization
source ./scripts/placement.tcl

# 4. Clock Tree Synthesis (CTS)
source ./scripts/cts.tcl

# 5. Global/Detail Routing & GDSII Export
source ./scripts/route.tcl
```

---

## 📋 Verification & Check Reports

The [`reports/`](reports/) directory contains Cadence Innovus verification logs:
- **[`chek_lef.txt`](reports/chek_lef.txt)**: Verifies physical library consistency and technology LEF rules.
- **[`netlist_check.txt`](reports/netlist_check.txt)**: Ensures no floating pins, dangling nets, or netlist syntax errors.
- **[`pin_check.txt`](reports/pin_check.txt)**: Confirms IO pin placement alignment along left/right core boundaries without overlaps.
# counter-physical-design-45nm
