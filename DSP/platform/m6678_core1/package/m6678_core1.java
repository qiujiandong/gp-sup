/*
 *  Do not modify this file; it is automatically 
 *  generated and any modifications will be overwritten.
 *
 * @(#) xdc-B21
 */
import java.util.*;
import org.mozilla.javascript.*;
import xdc.services.intern.xsr.*;
import xdc.services.spec.Session;

public class m6678_core1
{
    static final String VERS = "@(#) xdc-B21\n";

    static final Proto.Elm $$T_Bool = Proto.Elm.newBool();
    static final Proto.Elm $$T_Num = Proto.Elm.newNum();
    static final Proto.Elm $$T_Str = Proto.Elm.newStr();
    static final Proto.Elm $$T_Obj = Proto.Elm.newObj();

    static final Proto.Fxn $$T_Met = new Proto.Fxn(null, null, 0, -1, false);
    static final Proto.Map $$T_Map = new Proto.Map($$T_Obj);
    static final Proto.Arr $$T_Vec = new Proto.Arr($$T_Obj);

    static final XScriptO $$DEFAULT = Value.DEFAULT;
    static final Object $$UNDEF = Undefined.instance;

    static final Proto.Obj $$Package = (Proto.Obj)Global.get("$$Package");
    static final Proto.Obj $$Module = (Proto.Obj)Global.get("$$Module");
    static final Proto.Obj $$Instance = (Proto.Obj)Global.get("$$Instance");
    static final Proto.Obj $$Params = (Proto.Obj)Global.get("$$Params");

    static final Object $$objFldGet = Global.get("$$objFldGet");
    static final Object $$objFldSet = Global.get("$$objFldSet");
    static final Object $$proxyGet = Global.get("$$proxyGet");
    static final Object $$proxySet = Global.get("$$proxySet");
    static final Object $$delegGet = Global.get("$$delegGet");
    static final Object $$delegSet = Global.get("$$delegSet");

    Scriptable xdcO;
    Session ses;
    Value.Obj om;

    boolean isROV;
    boolean isCFG;

    Proto.Obj pkgP;
    Value.Obj pkgV;

    ArrayList<Object> imports = new ArrayList<Object>();
    ArrayList<Object> loggables = new ArrayList<Object>();
    ArrayList<Object> mcfgs = new ArrayList<Object>();
    ArrayList<Object> icfgs = new ArrayList<Object>();
    ArrayList<String> inherits = new ArrayList<String>();
    ArrayList<Object> proxies = new ArrayList<Object>();
    ArrayList<Object> sizes = new ArrayList<Object>();
    ArrayList<Object> tdefs = new ArrayList<Object>();

    void $$IMPORTS()
    {
        Global.callFxn("loadPackage", xdcO, "xdc");
        Global.callFxn("loadPackage", xdcO, "xdc.corevers");
        Global.callFxn("loadPackage", xdcO, "xdc.platform");
        Global.callFxn("loadPackage", xdcO, "ti.platforms.generic");
    }

    void $$OBJECTS()
    {
        pkgP = (Proto.Obj)om.bind("m6678_core1.Package", new Proto.Obj());
        pkgV = (Value.Obj)om.bind("m6678_core1", new Value.Obj("m6678_core1", pkgP));
    }

    void Platform$$OBJECTS()
    {
        Proto.Obj po, spo;
        Value.Obj vo;

        po = (Proto.Obj)om.bind("m6678_core1.Platform.Module", new Proto.Obj());
        vo = (Value.Obj)om.bind("m6678_core1.Platform", new Value.Obj("m6678_core1.Platform", po));
        pkgV.bind("Platform", vo);
        // decls 
        om.bind("m6678_core1.Platform.Board", om.findStrict("xdc.platform.IPlatform.Board", "m6678_core1"));
        om.bind("m6678_core1.Platform.Memory", om.findStrict("xdc.platform.IPlatform.Memory", "m6678_core1"));
        // insts 
        Object insP = om.bind("m6678_core1.Platform.Instance", new Proto.Obj());
        po = (Proto.Obj)om.bind("m6678_core1.Platform$$Object", new Proto.Obj());
        om.bind("m6678_core1.Platform.Object", new Proto.Str(po, true));
        po = (Proto.Obj)om.bind("m6678_core1.Platform$$Params", new Proto.Obj());
        om.bind("m6678_core1.Platform.Params", new Proto.Str(po, true));
    }

    void Platform$$CONSTS()
    {
        // module Platform
    }

    void Platform$$CREATES()
    {
        Proto.Fxn fxn;
        StringBuilder sb;

        fxn = (Proto.Fxn)om.bind("m6678_core1.Platform$$create", new Proto.Fxn(om.findStrict("m6678_core1.Platform.Module", "m6678_core1"), om.findStrict("m6678_core1.Platform.Instance", "m6678_core1"), 2, 1, false));
                fxn.addArg(0, "name", $$T_Str, $$UNDEF);
                fxn.addArg(1, "__params", (Proto)om.findStrict("m6678_core1.Platform.Params", "m6678_core1"), Global.newObject());
        sb = new StringBuilder();
        sb.append("m6678_core1$Platform$$create = function( name, __params ) {\n");
            sb.append("var __mod = xdc.om['m6678_core1.Platform'];\n");
            sb.append("var __inst = xdc.om['m6678_core1.Platform.Instance'].$$make();\n");
            sb.append("__inst.$$bind('$package', xdc.om['m6678_core1']);\n");
            sb.append("__inst.$$bind('$index', __mod.$instances.length);\n");
            sb.append("__inst.$$bind('$category', 'Instance');\n");
            sb.append("__inst.$$bind('$args', {name:name});\n");
            sb.append("__inst.$$bind('$module', __mod);\n");
            sb.append("__mod.$instances.$add(__inst);\n");
            sb.append("__inst.externalMemoryMap = __mod.PARAMS.externalMemoryMap;\n");
            sb.append("__inst.customMemoryMap = __mod.PARAMS.customMemoryMap;\n");
            sb.append("__inst.renameMap = __mod.PARAMS.renameMap;\n");
            sb.append("__inst.dataMemory = __mod.PARAMS.dataMemory;\n");
            sb.append("__inst.codeMemory = __mod.PARAMS.codeMemory;\n");
            sb.append("__inst.stackMemory = __mod.PARAMS.stackMemory;\n");
            sb.append("__inst.sectMap = __mod.PARAMS.sectMap;\n");
            sb.append("__inst.peripherals = __mod.PARAMS.peripherals;\n");
            sb.append("for (var __p in __params) __inst[__p] = __params[__p];\n");
            sb.append("var save = xdc.om.$curpkg;\n");
            sb.append("xdc.om.$$bind('$curpkg', __mod.$package.$name);\n");
            sb.append("__mod.instance$meta$init.$fxn.apply(__inst, [name]);\n");
            sb.append("xdc.om.$$bind('$curpkg', save);\n");
            sb.append("__inst.$$bless();\n");
            sb.append("return __inst;\n");
        sb.append("}\n");
        Global.eval(sb.toString());
        fxn = (Proto.Fxn)om.bind("m6678_core1.Platform$$construct", new Proto.Fxn(om.findStrict("m6678_core1.Platform.Module", "m6678_core1"), null, 3, 1, false));
                fxn.addArg(0, "__obj", (Proto)om.findStrict("m6678_core1.Platform$$Object", "m6678_core1"), null);
                fxn.addArg(1, "name", $$T_Str, $$UNDEF);
                fxn.addArg(2, "__params", (Proto)om.findStrict("m6678_core1.Platform.Params", "m6678_core1"), Global.newObject());
        sb = new StringBuilder();
        sb.append("m6678_core1$Platform$$construct = function( __obj, name, __params ) {\n");
            sb.append("var __mod = xdc.om['m6678_core1.Platform'];\n");
            sb.append("var __inst = __obj;\n");
            sb.append("__inst.$$bind('$args', {name:name});\n");
            sb.append("__inst.$$bind('$module', __mod);\n");
            sb.append("__mod.$objects.$add(__inst);\n");
            sb.append("__inst.externalMemoryMap = __mod.PARAMS.externalMemoryMap;\n");
            sb.append("__inst.customMemoryMap = __mod.PARAMS.customMemoryMap;\n");
            sb.append("__inst.renameMap = __mod.PARAMS.renameMap;\n");
            sb.append("__inst.dataMemory = __mod.PARAMS.dataMemory;\n");
            sb.append("__inst.codeMemory = __mod.PARAMS.codeMemory;\n");
            sb.append("__inst.stackMemory = __mod.PARAMS.stackMemory;\n");
            sb.append("__inst.sectMap = __mod.PARAMS.sectMap;\n");
            sb.append("__inst.peripherals = __mod.PARAMS.peripherals;\n");
            sb.append("for (var __p in __params) __inst[__p] = __params[__p];\n");
            sb.append("__inst.$$bless();\n");
            sb.append("return null;\n");
        sb.append("}\n");
        Global.eval(sb.toString());
    }

    void Platform$$FUNCTIONS()
    {
        Proto.Fxn fxn;

    }

    void Platform$$SIZES()
    {
    }

    void Platform$$TYPES()
    {
        Scriptable cap;
        Proto.Obj po;
        Proto.Str ps;
        Proto.Typedef pt;
        Object fxn;

        cap = (Scriptable)Global.callFxn("loadCapsule", xdcO, "m6678_core1/Platform.xs");
        om.bind("m6678_core1.Platform$$capsule", cap);
        po = (Proto.Obj)om.findStrict("m6678_core1.Platform.Module", "m6678_core1");
        po.init("m6678_core1.Platform.Module", om.findStrict("xdc.platform.IPlatform.Module", "m6678_core1"));
                po.addFld("$hostonly", $$T_Num, 1, "r");
        po.addFld("CPU", (Proto)om.findStrict("ti.platforms.generic.Platform.Instance", "m6678_core1"), $$UNDEF, "wh");
                po.addFxn("create", (Proto.Fxn)om.findStrict("m6678_core1.Platform$$create", "m6678_core1"), Global.get("m6678_core1$Platform$$create"));
                po.addFxn("construct", (Proto.Fxn)om.findStrict("m6678_core1.Platform$$construct", "m6678_core1"), Global.get("m6678_core1$Platform$$construct"));
        fxn = Global.get(cap, "module$use");
        if (fxn != null) om.bind("m6678_core1.Platform$$module$use", true);
        if (fxn != null) po.addFxn("module$use", $$T_Met, fxn);
        fxn = Global.get(cap, "module$meta$init");
        if (fxn != null) om.bind("m6678_core1.Platform$$module$meta$init", true);
        if (fxn != null) po.addFxn("module$meta$init", $$T_Met, fxn);
        fxn = Global.get(cap, "instance$meta$init");
        if (fxn != null) om.bind("m6678_core1.Platform$$instance$meta$init", true);
        if (fxn != null) po.addFxn("instance$meta$init", $$T_Met, fxn);
        fxn = Global.get(cap, "module$validate");
        if (fxn != null) om.bind("m6678_core1.Platform$$module$validate", true);
        if (fxn != null) po.addFxn("module$validate", $$T_Met, fxn);
        po = (Proto.Obj)om.findStrict("m6678_core1.Platform.Instance", "m6678_core1");
        po.init("m6678_core1.Platform.Instance", om.findStrict("xdc.platform.IPlatform.Instance", "m6678_core1"));
                po.addFld("$hostonly", $$T_Num, 1, "r");
        po.addFld("codeMemory", $$T_Str, "L2SRAM", "wh");
        po.addFld("dataMemory", $$T_Str, "MSMC", "wh");
        po.addFld("stackMemory", $$T_Str, "L2SRAM", "wh");
        po.addFld("l2Mode", $$T_Str, "128k", "wh");
        po.addFld("l1PMode", $$T_Str, "32k", "wh");
        po.addFld("l1DMode", $$T_Str, "32k", "wh");
                fxn = Global.get(cap, "getCpuDataSheet");
                if (fxn != null) po.addFxn("getCpuDataSheet", (Proto.Fxn)om.findStrict("xdc.platform.IPlatform$$getCpuDataSheet", "m6678_core1"), fxn);
                fxn = Global.get(cap, "getCreateArgs");
                if (fxn != null) po.addFxn("getCreateArgs", (Proto.Fxn)om.findStrict("xdc.platform.IPlatform$$getCreateArgs", "m6678_core1"), fxn);
                fxn = Global.get(cap, "getExeContext");
                if (fxn != null) po.addFxn("getExeContext", (Proto.Fxn)om.findStrict("xdc.platform.IPlatform$$getExeContext", "m6678_core1"), fxn);
                fxn = Global.get(cap, "getExecCmd");
                if (fxn != null) po.addFxn("getExecCmd", (Proto.Fxn)om.findStrict("xdc.platform.IPlatform$$getExecCmd", "m6678_core1"), fxn);
                fxn = Global.get(cap, "getLinkTemplate");
                if (fxn != null) po.addFxn("getLinkTemplate", (Proto.Fxn)om.findStrict("xdc.platform.IPlatform$$getLinkTemplate", "m6678_core1"), fxn);
        po = (Proto.Obj)om.findStrict("m6678_core1.Platform$$Params", "m6678_core1");
        po.init("m6678_core1.Platform.Params", om.findStrict("xdc.platform.IPlatform$$Params", "m6678_core1"));
                po.addFld("$hostonly", $$T_Num, 1, "r");
        po.addFld("codeMemory", $$T_Str, "L2SRAM", "wh");
        po.addFld("dataMemory", $$T_Str, "MSMC", "wh");
        po.addFld("stackMemory", $$T_Str, "L2SRAM", "wh");
        po.addFld("l2Mode", $$T_Str, "128k", "wh");
        po.addFld("l1PMode", $$T_Str, "32k", "wh");
        po.addFld("l1DMode", $$T_Str, "32k", "wh");
        po = (Proto.Obj)om.findStrict("m6678_core1.Platform$$Object", "m6678_core1");
        po.init("m6678_core1.Platform.Object", om.findStrict("m6678_core1.Platform.Instance", "m6678_core1"));
                fxn = Global.get(cap, "getCpuDataSheet");
                if (fxn != null) po.addFxn("getCpuDataSheet", (Proto.Fxn)om.findStrict("xdc.platform.IPlatform$$getCpuDataSheet", "m6678_core1"), fxn);
                fxn = Global.get(cap, "getCreateArgs");
                if (fxn != null) po.addFxn("getCreateArgs", (Proto.Fxn)om.findStrict("xdc.platform.IPlatform$$getCreateArgs", "m6678_core1"), fxn);
                fxn = Global.get(cap, "getExeContext");
                if (fxn != null) po.addFxn("getExeContext", (Proto.Fxn)om.findStrict("xdc.platform.IPlatform$$getExeContext", "m6678_core1"), fxn);
                fxn = Global.get(cap, "getExecCmd");
                if (fxn != null) po.addFxn("getExecCmd", (Proto.Fxn)om.findStrict("xdc.platform.IPlatform$$getExecCmd", "m6678_core1"), fxn);
                fxn = Global.get(cap, "getLinkTemplate");
                if (fxn != null) po.addFxn("getLinkTemplate", (Proto.Fxn)om.findStrict("xdc.platform.IPlatform$$getLinkTemplate", "m6678_core1"), fxn);
    }

    void Platform$$ROV()
    {
    }

    void $$SINGLETONS()
    {
        pkgP.init("m6678_core1.Package", (Proto.Obj)om.findStrict("xdc.IPackage.Module", "m6678_core1"));
        pkgP.bind("$capsule", $$UNDEF);
        pkgV.init2(pkgP, "m6678_core1", Value.DEFAULT, false);
        pkgV.bind("$name", "m6678_core1");
        pkgV.bind("$category", "Package");
        pkgV.bind("$$qn", "m6678_core1.");
        pkgV.bind("$vers", Global.newArray());
        Value.Map atmap = (Value.Map)pkgV.getv("$attr");
        atmap.seal("length");
        imports.clear();
        pkgV.bind("$imports", imports);
        StringBuilder sb = new StringBuilder();
        sb.append("var pkg = xdc.om['m6678_core1'];\n");
        sb.append("if (pkg.$vers.length >= 3) {\n");
            sb.append("pkg.$vers.push(Packages.xdc.services.global.Vers.getDate(xdc.csd() + '/..'));\n");
        sb.append("}\n");
        sb.append("if ('m6678_core1$$stat$base' in xdc.om) {\n");
            sb.append("pkg.packageBase = xdc.om['m6678_core1$$stat$base'];\n");
            sb.append("pkg.packageRepository = xdc.om['m6678_core1$$stat$root'];\n");
        sb.append("}\n");
        sb.append("pkg.build.libraries = [\n");
        sb.append("];\n");
        sb.append("pkg.build.libDesc = [\n");
        sb.append("];\n");
        Global.eval(sb.toString());
    }

    void Platform$$SINGLETONS()
    {
        Proto.Obj po;
        Value.Obj vo;

        vo = (Value.Obj)om.findStrict("m6678_core1.Platform", "m6678_core1");
        po = (Proto.Obj)om.findStrict("m6678_core1.Platform.Module", "m6678_core1");
        vo.init2(po, "m6678_core1.Platform", $$DEFAULT, false);
        vo.bind("Module", po);
        vo.bind("$category", "Module");
        vo.bind("$capsule", om.findStrict("m6678_core1.Platform$$capsule", "m6678_core1"));
        vo.bind("Instance", om.findStrict("m6678_core1.Platform.Instance", "m6678_core1"));
        vo.bind("Params", om.findStrict("m6678_core1.Platform.Params", "m6678_core1"));
        vo.bind("PARAMS", ((Proto.Str)om.findStrict("m6678_core1.Platform.Params", "m6678_core1")).newInstance());
        vo.bind("$package", om.findStrict("m6678_core1", "m6678_core1"));
        tdefs.clear();
        proxies.clear();
        mcfgs.clear();
        icfgs.clear();
        inherits.clear();
        vo.bind("Board", om.findStrict("xdc.platform.IPlatform.Board", "m6678_core1"));
        tdefs.add(om.findStrict("xdc.platform.IPlatform.Board", "m6678_core1"));
        vo.bind("Memory", om.findStrict("xdc.platform.IPlatform.Memory", "m6678_core1"));
        tdefs.add(om.findStrict("xdc.platform.IPlatform.Memory", "m6678_core1"));
        vo.bind("MemoryMap", om.findStrict("xdc.platform.IPlatform.MemoryMap", "m6678_core1"));
        vo.bind("$$tdefs", Global.newArray(tdefs.toArray()));
        vo.bind("$$proxies", Global.newArray(proxies.toArray()));
        vo.bind("$$mcfgs", Global.newArray(mcfgs.toArray()));
        vo.bind("$$icfgs", Global.newArray(icfgs.toArray()));
        inherits.add("xdc.platform");
        vo.bind("$$inherits", Global.newArray(inherits.toArray()));
        ((Value.Arr)pkgV.getv("$modules")).add(vo);
        ((Value.Arr)om.findStrict("$modules", "m6678_core1")).add(vo);
        vo.bind("$$instflag", 1);
        vo.bind("$$iobjflag", 1);
        vo.bind("$$sizeflag", 1);
        vo.bind("$$dlgflag", 0);
        vo.bind("$$iflag", 1);
        vo.bind("$$romcfgs", "|");
        vo.bind("$$nortsflag", 0);
        Proto.Str ps = (Proto.Str)vo.find("Module_State");
        if (ps != null) vo.bind("$object", ps.newInstance());
        vo.bind("$$meta_iobj", om.has("m6678_core1.Platform$$instance$static$init", null) ? 1 : 0);
        vo.bind("$$fxntab", Global.newArray());
        vo.bind("$$logEvtCfgs", Global.newArray());
        vo.bind("$$errorDescCfgs", Global.newArray());
        vo.bind("$$assertDescCfgs", Global.newArray());
        Value.Map atmap = (Value.Map)vo.getv("$attr");
        atmap.seal("length");
        vo.bind("Object", om.findStrict("m6678_core1.Platform.Object", "m6678_core1"));
        pkgV.bind("Platform", vo);
        ((Value.Arr)pkgV.getv("$unitNames")).add("Platform");
    }

    void $$INITIALIZATION()
    {
        Value.Obj vo;

        if (isCFG) {
        }//isCFG
        Global.callFxn("module$meta$init", (Scriptable)om.findStrict("m6678_core1.Platform", "m6678_core1"));
        vo = (Value.Obj)om.findStrict("m6678_core1.Platform", "m6678_core1");
        Global.put(vo, "CPU", Global.callFxn("create", (Scriptable)om.find("ti.platforms.generic.Platform"), "CPU", Global.newObject("clockRate", 1000L, "catalogName", "ti.catalog.c6000", "deviceName", "TMS320C6678", "customMemoryMap", Global.newArray(new Object[]{Global.newArray(new Object[]{"MSMC_SHARED", Global.newObject("name", "MSMC_SHARED", "base", 0x0c000000L, "len", 0x00080000L, "space", "code/data", "access", "RWX")}), Global.newArray(new Object[]{"DDR3_SHARED", Global.newObject("name", "DDR3_SHARED", "base", 0x80000000L, "len", 0x40000000L, "space", "code/data", "access", "RWX")}), Global.newArray(new Object[]{"MSMC", Global.newObject("name", "MSMC", "base", 0x0c100000L, "len", 0x00180000L, "space", "code/data", "access", "RWX")}), Global.newArray(new Object[]{"DDR3", Global.newObject("name", "DDR3", "base", 0xc8000000L, "len", 0x08000000L, "space", "code/data", "access", "RWX")}), Global.newArray(new Object[]{"L2SRAM", Global.newObject("name", "L2SRAM", "base", 0x00800000L, "len", 0x00060000L, "space", "code/data", "access", "RWX")})}), "l2Mode", "128k", "l1PMode", "32k", "l1DMode", "32k")));
        Global.callFxn("init", pkgV);
        ((Value.Obj)om.getv("m6678_core1.Platform")).bless();
        ((Value.Arr)om.findStrict("$packages", "m6678_core1")).add(pkgV);
    }

    public void exec( Scriptable xdcO, Session ses )
    {
        this.xdcO = xdcO;
        this.ses = ses;
        om = (Value.Obj)xdcO.get("om", null);

        Object o = om.geto("$name");
        String s = o instanceof String ? (String)o : null;
        isCFG = s != null && s.equals("cfg");
        isROV = s != null && s.equals("rov");

        $$IMPORTS();
        $$OBJECTS();
        Platform$$OBJECTS();
        Platform$$CONSTS();
        Platform$$CREATES();
        Platform$$FUNCTIONS();
        Platform$$SIZES();
        Platform$$TYPES();
        if (isROV) {
            Platform$$ROV();
        }//isROV
        $$SINGLETONS();
        Platform$$SINGLETONS();
        $$INITIALIZATION();
    }
}
