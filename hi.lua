-- ===== Enhanced Aura HTML DUI Menu System =====

-- متغيرات النظام
local AuraDUI = {
    dui = nil,
    duiHandle = nil,
    txd = nil,
    texture = nil,
    isVisible = false,
    authenticated = false,
    currentCategory = nil,
    retryCount = 0,
    maxRetries = 3
}

-- إعدادات المنيو المحدثة
local MENU_CONFIG = {
    -- الرابط الجديد
    url = "https://raw.githubusercontent.com/bv3d05/gdffdga/refs/heads/main/index.html",
    -- رابط بديل في حالة فشل الأول
    fallbackUrl = "https://htmlpreview.github.io/?https://github.com/bv3d05/gdffdga/blob/main/index.html",
    width = 800,
    height = 600,
    posX = 0.5,     -- وسط الشاشة
    posY = 0.5,     -- وسط الشاشة
    scaleX = 0.4,   -- حجم أكبر
    scaleY = 0.5
}

-- ===== وظائف النظام المحسنة =====

-- إنشاء DUI مع معالجة أخطاء محسنة
function CreateAuraDUI(useFailsafe)
    local currentUrl = useFailsafe and MENU_CONFIG.fallbackUrl or MENU_CONFIG.url
    
    print("Creating Aura DUI...")
    print("Using URL: " .. currentUrl)
    
    -- تدمير DUI السابق إن وجد
    if AuraDUI.dui then
        DestroyAuraDUI()
        Wait(500)
    end
    
    -- إنشاء DUI من رابط HTML
    AuraDUI.dui = CreateDui(currentUrl, MENU_CONFIG.width, MENU_CONFIG.height)
    
    if not AuraDUI.dui then
        print("❌ Failed to create DUI")
        
        -- محاولة الرابط البديل
        if not useFailsafe and AuraDUI.retryCount < AuraDUI.maxRetries then
            AuraDUI.retryCount = AuraDUI.retryCount + 1
            print("🔄 Trying fallback URL...")
            Wait(1000)
            return CreateAuraDUI(true)
        end
        
        return false
    end
    
    -- انتظار تحميل DUI
    Wait(2000)
    
    -- الحصول على handle
    AuraDUI.duiHandle = GetDuiHandle(AuraDUI.dui)
    
    if not AuraDUI.duiHandle then
        print("❌ Failed to get DUI handle")
        DestroyDui(AuraDUI.dui)
        AuraDUI.dui = nil
        return false
    end
    
    -- إنشاء texture dictionary
    AuraDUI.txd = CreateRuntimeTxd("aura_menu_txd")
    
    if not AuraDUI.txd then
        print("❌ Failed to create texture dictionary")
        return false
    end
    
    -- إنشاء texture من DUI
    AuraDUI.texture = CreateRuntimeTextureFromDuiHandle(AuraDUI.txd, "aura_menu_tex", AuraDUI.duiHandle)
    
    if not AuraDUI.texture then
        print("❌ Failed to create texture from DUI")
        return false
    end
    
    print("✅ Aura DUI created successfully")
    AuraDUI.isVisible = true
    AuraDUI.retryCount = 0
    
    -- إرسال رسالة تأكيد للـ HTML
    Wait(3000)
    SendMessageToDUI({
        type = "system_ready",
        message = "DUI System Online",
        timestamp = GetGameTimer()
    })
    
    return true
end

-- تدمير DUI
function DestroyAuraDUI()
    if AuraDUI.dui then
        DestroyDui(AuraDUI.dui)
        AuraDUI.dui = nil
        AuraDUI.duiHandle = nil
        AuraDUI.texture = nil
        AuraDUI.txd = nil
        AuraDUI.isVisible = false
        print("🗑️ Aura DUI destroyed")
    end
end

-- إرسال رسالة للـ HTML مع معالجة أخطاء
function SendMessageToDUI(message)
    if AuraDUI.dui then
        local success = pcall(function()
            SendDuiMessage(AuraDUI.dui, json.encode(message))
        end)
        
        if success then
            print("📤 Message sent to DUI: " .. (message.type or "unknown"))
        else
            print("❌ Failed to send message to DUI")
        end
    else
        print("⚠️ Cannot send message - DUI not available")
    end
end

-- معالج رسائل من HTML محسن
function HandleDUIMessage(data)
    print("📥 Received message from HTML: " .. (data.type or "unknown"))
    
    if data.type == "aura_authenticated" then
        AuraDUI.authenticated = true
        print("✅ Authentication successful for key: " .. (data.key or "unknown"))
        
        -- إرسال تأكيد للـ HTML
        SendMessageToDUI({
            type = "auth_confirmed",
            status = "success",
            message = "Access granted"
        })
        
    elseif data.type == "aura_category_selected" then
        AuraDUI.currentCategory = data.category
        print("📂 Category selected: " .. (data.category or "unknown"))
        HandleCategorySelection(data.category)
        
    elseif data.type == "aura_option_selected" then
        print("⚡ Option executed: " .. (data.option or "unknown"))
        print("working")
        
        -- إرسال تأكيد التنفيذ
        SendMessageToDUI({
            type = "execution_confirmed",
            option = data.option,
            status = "completed"
        })
        
    elseif data.type == "aura_ready" then
        print("✅ HTML interface ready")
        
    elseif data.type == "aura_error" then
        print("❌ HTML Error: " .. (data.message or "unknown error"))
        
    elseif data.type == "ping" then
        -- Heartbeat من HTML
        SendMessageToDUI({
            type = "pong",
            timestamp = GetGameTimer()
        })
    end
end

-- معالج اختيار الفئات محسن
function HandleCategorySelection(category)
    if not AuraDUI.authenticated then
        print("❌ User not authenticated")
        SendMessageToDUI({
            type = "access_denied",
            message = "Authentication required"
        })
        return
    end
    
    print("🎯 Processing category: " .. (category or "unknown"))
    
    -- تنفيذ الوظائف حسب الفئة المختارة
    if category == "self" then
        print("👤 Opening player options...")
        -- إضافة وظائف اللاعب هنا
        
    elseif category == "online" then
        print("🌐 Opening online players menu...")
        -- عرض قائمة اللاعبين المتصلين
        
    elseif category == "weapons" then
        print("🔫 Opening weapons menu...")
        -- قائمة الأسلحة والقتال
        
    elseif category == "visual" then
        print("👁️ Opening visual effects...")
        -- تأثيرات بصرية
        
    elseif category == "vehicle" then
        print("🚗 Opening vehicle options...")
        -- خيارات المركبات
        
    elseif category == "world" then
        print("🌍 Opening world options...")
        -- خيارات العالم
        
    elseif category == "misc" then
        print("📦 Opening miscellaneous...")
        -- متنوعات
        
    elseif category == "settings" then
        print("⚙️ Opening settings...")
        -- الإعدادات
    end
    
    -- إرسال تأكيد تنفيذ الفئة
    SendMessageToDUI({
        type = "category_processed",
        category = category,
        status = "active"
    })
end

-- تبديل رؤية المنيو
function ToggleAuraMenu()
    if AuraDUI.isVisible then
        AuraDUI.isVisible = false
        print("🙈 Menu hidden")
    else
        if not AuraDUI.dui then
            CreateAuraDUI()
        end
        AuraDUI.isVisible = true
        print("👁️ Menu shown")
    end
end

-- إعادة تحميل المنيو
function ReloadAuraMenu()
    print("🔄 Reloading Aura Menu...")
    DestroyAuraDUI()
    Wait(1000)
    CreateAuraDUI()
end

-- ===== Thread الرسم =====

CreateThread(function()
    -- انتظار تحميل النظام
    Wait(3000)
    
    -- إنشاء DUI عند البدء
    CreateAuraDUI()
    
    while true do
        Wait(0)
        
        -- رسم DUI على الشاشة
        if AuraDUI.isVisible and AuraDUI.txd and AuraDUI.texture then
            DrawSprite("aura_menu_txd", "aura_menu_tex", 
                      MENU_CONFIG.posX, MENU_CONFIG.posY, 
                      MENU_CONFIG.scaleX, MENU_CONFIG.scaleY, 
                      0.0, 255, 255, 255, 255)
        end
    end
end)

-- ===== Thread التحكم =====

CreateThread(function()
    while true do
        Wait(0)
        
        -- تبديل المنيو بـ F1
        if IsControlJustPressed(0, 288) then -- F1
            ToggleAuraMenu()
        end
        
        -- إعادة تحميل بـ F2
        if IsControlJustPressed(0, 289) then -- F2
            ReloadAuraMenu()
        end
        
        -- إخفاء بـ ESC
        if IsControlJustPressed(0, 322) and AuraDUI.isVisible then -- ESC
            AuraDUI.isVisible = false
            print("Menu hidden with ESC")
        end
    end
end)

-- ===== معالج الأحداث =====

-- استقبال رسائل من HTML
RegisterNUICallback('messageHandler', function(data, cb)
    HandleDUIMessage(data)
    cb('ok')
end)

-- أوامر الشات
RegisterCommand('aura', function()
    ToggleAuraMenu()
end, false)

RegisterCommand('aurareload', function()
    ReloadAuraMenu()
end, false)

RegisterCommand('auratest', function()
    if AuraDUI.dui then
        SendMessageToDUI({
            type = "test_message",
            message = "Test from Lua",
            timestamp = GetGameTimer()
        })
        print("Test message sent to HTML")
    else
        print("DUI not available for testing")
    end
end, false)

RegisterCommand('auraurl', function()
    print("Current URL: " .. MENU_CONFIG.url)
    print("Fallback URL: " .. MENU_CONFIG.fallbackUrl)
end, false)

-- تنظيف عند إنهاء الـ resource
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    
    DestroyAuraDUI()
    print("Aura DUI system cleaned up")
end)

-- رسائل البدء محسنة
print("==========================================")
print("🌟 ENHANCED AURA HTML DUI MENU SYSTEM 🌟")
print("==========================================")
print("📡 Primary URL: " .. MENU_CONFIG.url)
print("🔄 Fallback URL: " .. MENU_CONFIG.fallbackUrl)
print("🎮 Controls:")
print("   F1: Toggle Menu")
print("   F2: Reload Menu")
print("   ESC: Hide Menu")
print("💬 Commands:")
print("   /aura - Toggle menu")
print("   /aurareload - Reload menu")
print("   /auratest - Send test message")
print("   /auraurl - Show current URLs")
print("==========================================")

-- فحص حالة DUI مع تأخير
CreateThread(function()
    Wait(8000) -- انتظار 8 ثوان
    
    if AuraDUI.isVisible and AuraDUI.dui then
        print("✅ Aura DUI System: ONLINE")
        print("🎯 Ready to receive commands")
        
        -- إرسال رسالة اختبار
        SendMessageToDUI({
            type = "system_check",
            message = "System operational",
            version = "2.0"
        })
    else
        print("❌ Aura DUI System: OFFLINE")
        print("🔧 Try using /aurareload or F2 to fix")
        
        -- محاولة إعادة التحميل التلقائي
        print("🔄 Attempting auto-recovery...")
        ReloadAuraMenu()
    end
end)
