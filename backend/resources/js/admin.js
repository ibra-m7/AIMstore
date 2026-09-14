import axios from "axios";
import * as bootstrap from "bootstrap";
import "bootstrap/dist/css/bootstrap.rtl.min.css";
import "bootstrap-icons/font/bootstrap-icons.css";
import "../css/admin.css";

window.axios = axios;
window.axios.defaults.headers.common["X-Requested-With"] = "XMLHttpRequest";
const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content");
if (csrfToken) {
    window.axios.defaults.headers.common["X-CSRF-TOKEN"] = csrfToken;
}
window.bootstrap = bootstrap;

const sidebarShell = document.getElementById("adminShell");
const sidebarKey = "aimstore-admin-sidebar-collapsed";
const desktopQuery = window.matchMedia("(min-width: 1200px)");

const persistSidebar = () => {
    if (!sidebarShell || !desktopQuery.matches) {
        return;
    }

    localStorage.setItem(
        sidebarKey,
        sidebarShell.classList.contains("sidebar-collapsed") ? "1" : "0",
    );
};

const closeMobileSidebar = () => {
    sidebarShell?.classList.remove("sidebar-open");
};

const syncSidebarMode = () => {
    if (!sidebarShell) {
        return;
    }

    if (desktopQuery.matches) {
        sidebarShell.classList.remove("sidebar-open");
        if (localStorage.getItem(sidebarKey) === "1") {
            sidebarShell.classList.add("sidebar-collapsed");
        }
        return;
    }

    sidebarShell.classList.remove("sidebar-collapsed");
};

syncSidebarMode();
desktopQuery.addEventListener("change", syncSidebarMode);

document.querySelector("[data-sidebar-toggle]")?.addEventListener("click", () => {
    if (!sidebarShell) {
        return;
    }

    if (!desktopQuery.matches) {
        sidebarShell.classList.toggle("sidebar-open");
        return;
    }

    sidebarShell.classList.toggle("sidebar-collapsed");
    persistSidebar();
});

document.querySelector("[data-sidebar-backdrop]")?.addEventListener("click", closeMobileSidebar);
document.querySelector("[data-sidebar-close]")?.addEventListener("click", closeMobileSidebar);

document.querySelectorAll("[data-nav-group-toggle]").forEach((toggle) => {
    toggle.addEventListener("click", (event) => {
        event.preventDefault();
        const group = toggle.closest("[data-nav-group]");
        if (!group) {
            return;
        }
        const willOpen = !group.classList.contains("is-open");
        document.querySelectorAll("[data-nav-group].is-open").forEach((other) => {
            if (other !== group && !other.classList.contains("is-active")) {
                other.classList.remove("is-open");
                other.querySelector("[data-nav-group-toggle]")?.setAttribute("aria-expanded", "false");
            }
        });
        group.classList.toggle("is-open", willOpen);
        toggle.setAttribute("aria-expanded", willOpen ? "true" : "false");
    });
});

document.addEventListener("change", (event) => {
    const input = event.target.closest("[data-image-preview]");
    if (!(input instanceof HTMLInputElement)) {
        return;
    }
    const preview = document.querySelector(input.dataset.imagePreview);
    const file = input.files?.[0];
    if (!preview || !file) {
        return;
    }
    preview.src = URL.createObjectURL(file);
    preview.hidden = false;
    const fallback = document.querySelector("[data-profile-avatar-fallback]");
    if (fallback) {
        fallback.hidden = true;
    }
});

document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
        closeMobileSidebar();
    }
});

document.addEventListener("keydown", (event) => {
    if (event.key !== "/" || event.ctrlKey || event.metaKey || event.altKey) {
        return;
    }
    const tag = document.activeElement?.tagName;
    if (tag === "INPUT" || tag === "TEXTAREA" || tag === "SELECT") {
        return;
    }
    const search = document.querySelector(".admin-search input");
    if (!search) {
        return;
    }
    event.preventDefault();
    search.focus();
});

const syncColorLabel = (input) => {
    const label = input.dataset.colorSync ? document.querySelector(input.dataset.colorSync) : null;
    if (label) {
        label.textContent = input.value;
    }

    const preview = input.dataset.colorPreview ? document.querySelector(input.dataset.colorPreview) : null;
    if (preview) {
        preview.style.background = input.value;
    }
};

document.querySelectorAll("[data-color-sync]").forEach(syncColorLabel);
document.addEventListener("input", (event) => {
    const input = event.target.closest("[data-color-sync]");
    if (input) {
        syncColorLabel(input);
    }
});

const syncHomeSectionBackgroundToggle = (checkbox) => {
    const target = document.querySelector(checkbox.dataset.homeSectionBgToggle);
    if (!target) {
        return;
    }
    const useDefault = checkbox.checked;
    target.disabled = useDefault;
    target.classList.toggle("opacity-50", useDefault);
};

const bindHomeSectionBackgroundToggle = () => {
    document.querySelectorAll("[data-home-section-bg-toggle]").forEach((checkbox) => {
        if (checkbox.dataset.homeSectionBgBound === "1") {
            return;
        }
        checkbox.dataset.homeSectionBgBound = "1";
        syncHomeSectionBackgroundToggle(checkbox);
        checkbox.addEventListener("change", () => syncHomeSectionBackgroundToggle(checkbox));
    });
};

bindHomeSectionBackgroundToggle();
window.addEventListener("admin:content-ready", bindHomeSectionBackgroundToggle);

const syncLinkPanels = (select) => {
    const value = select.value;
    document.querySelectorAll("[data-link-panel]").forEach((panel) => {
        panel.hidden = panel.dataset.linkPanel !== value;
    });
};

document.querySelectorAll("[data-link-type]").forEach(syncLinkPanels);
document.addEventListener("change", (event) => {
    const select = event.target.closest("[data-link-type]");
    if (select) {
        syncLinkPanels(select);
    }
});

document.addEventListener("input", (event) => {
    const input = event.target.closest("[data-picker-search]");
    if (!input) {
        return;
    }
    const root = document.querySelector(input.dataset.pickerSearch);
    if (!root) {
        return;
    }
    const term = input.value.trim().toLowerCase();
    root.querySelectorAll("[data-picker-text]").forEach((item) => {
        const text = (item.dataset.pickerText || "").toLowerCase();
        item.hidden = term !== "" && !text.includes(term);
    });
});

const setText = (el, value) => {
    if (el) {
        el.textContent = value || "";
    }
};

const fillDetailModal = (data) => {
    const modal = document.getElementById("adminDetailModal");
    if (!modal || !data) {
        return;
    }

    setText(modal.querySelector("[data-detail-title]"), data.title);
    const hero = modal.querySelector("[data-detail-hero]");
    const image = modal.querySelector("[data-detail-image]");
    if (hero && image) {
        if (data.image) {
            image.src = data.image;
            hero.hidden = false;
        } else {
            image.removeAttribute("src");
            hero.hidden = true;
        }
    }

    const badges = modal.querySelector("[data-detail-badges]");
    if (badges) {
        badges.replaceChildren();
        (data.badges || []).forEach((label) => {
            const badge = document.createElement("span");
            badge.className = "badge badge-soft";
            badge.textContent = label;
            badges.append(badge);
        });
    }

    const fields = modal.querySelector("[data-detail-fields]");
    if (fields) {
        fields.replaceChildren();
        (data.fields || []).forEach((row) => {
            const dt = document.createElement("dt");
            dt.textContent = row.label || "";
            const dd = document.createElement("dd");
            if (row.map_url) {
                const link = document.createElement("a");
                link.href = row.map_url;
                link.target = "_blank";
                link.rel = "noopener noreferrer";
                link.className = "map-link";
                const icon = document.createElement("i");
                icon.className = "bi bi-geo-alt-fill";
                link.append(icon, document.createTextNode(row.value || "عرض على الخريطة"));
                dd.append(link);
            } else {
                dd.textContent = row.value || "—";
            }
            if (row.label === "اللون" && row.value) {
                const dot = document.createElement("span");
                dot.className = "color-dot";
                dot.style.background = row.value;
                dd.prepend(dot);
            }
            fields.append(dt, dd);
        });
    }

    const blocks = modal.querySelector("[data-detail-blocks]");
    if (blocks) {
        blocks.replaceChildren();
        (data.blocks || []).forEach((block) => {
            const wrap = document.createElement("div");
            wrap.className = "detail-block";
            const title = document.createElement("h6");
            title.textContent = block.label || "";
            wrap.append(title);
            if (Array.isArray(block.list) && block.list.length) {
                const list = document.createElement("ul");
                block.list.forEach((item) => {
                    const li = document.createElement("li");
                    li.textContent = item;
                    list.append(li);
                });
                wrap.append(list);
            } else if (Array.isArray(block.cards) && block.cards.length) {
                const grid = document.createElement("div");
                grid.className = "detail-cards";
                block.cards.forEach((card) => {
                    const article = document.createElement("article");
                    article.className = "detail-card";
                    const head = document.createElement("div");
                    head.className = "detail-card-head";
                    const title = document.createElement("strong");
                    title.textContent = card.title || "";
                    head.append(title);
                    if (card.badge) {
                        const badge = document.createElement("span");
                        badge.className = "badge badge-soft";
                        badge.textContent = card.badge;
                        head.append(badge);
                    }
                    article.append(head);
                    if (card.text) {
                        const text = document.createElement("p");
                        text.textContent = card.text;
                        article.append(text);
                    }
                    if (card.meta) {
                        const meta = document.createElement("small");
                        meta.textContent = card.meta;
                        article.append(meta);
                    }
                    if (card.map_url) {
                        const link = document.createElement("a");
                        link.href = card.map_url;
                        link.target = "_blank";
                        link.rel = "noopener noreferrer";
                        link.className = "map-link";
                        const icon = document.createElement("i");
                        icon.className = "bi bi-geo-alt-fill";
                        link.append(icon, document.createTextNode("عرض الموقع على الخريطة"));
                        article.append(link);
                    }
                    grid.append(article);
                });
                wrap.append(grid);
            } else if (block.text) {
                const p = document.createElement("p");
                p.textContent = block.text;
                wrap.append(p);
            }
            blocks.append(wrap);
        });
    }

    const edit = modal.querySelector("[data-detail-edit]");
    if (edit) {
        edit.href = data.edit_url || "#";
        edit.hidden = !data.edit_url;
    }
};

document.addEventListener("click", (event) => {
    const button = event.target.closest("[data-detail]");
    if (!button) {
        return;
    }

    let payload = {};
    try {
        payload = JSON.parse(button.getAttribute("data-detail") || "{}");
    } catch {
        payload = {};
    }
    fillDetailModal(payload);
    const modal = document.getElementById("adminDetailModal");
    if (modal) {
        window.bootstrap.Modal.getOrCreateInstance(modal).show();
    }
});

const isModifiedClick = (event) =>
    event.metaKey || event.ctrlKey || event.shiftKey || event.altKey || event.button !== 0;

let ajaxController = null;
let adminMutating = false;
let adminProgressTimer = null;
let adminProgressValue = 0;

const getAdminProgress = () => document.getElementById("adminProgress");
const getAdminProgressBar = () => document.querySelector("[data-admin-progress-bar]");

const setAdminProgressWidth = (value) => {
    adminProgressValue = Math.max(0, Math.min(100, value));
    const bar = getAdminProgressBar();
    if (bar) {
        bar.style.width = `${adminProgressValue}%`;
        bar.style.opacity = "1";
    }
};

const startAdminProgress = () => {
    const root = getAdminProgress();
    const bar = getAdminProgressBar();
    if (!root || !bar) {
        return;
    }

    window.clearInterval(adminProgressTimer);
    root.hidden = false;
    root.setAttribute("aria-hidden", "false");
    root.classList.remove("is-finishing");
    bar.style.transition = "none";
    setAdminProgressWidth(0);
    // Force reflow so the width animation starts cleanly.
    void bar.offsetWidth;
    bar.style.transition = "";
    setAdminProgressWidth(18);

    adminProgressTimer = window.setInterval(() => {
        if (adminProgressValue >= 86) {
            return;
        }
        const step = adminProgressValue < 40 ? 9 : adminProgressValue < 70 ? 4 : 1.5;
        setAdminProgressWidth(adminProgressValue + step);
    }, 220);
};

const finishAdminProgress = () => {
    const root = getAdminProgress();
    const bar = getAdminProgressBar();
    window.clearInterval(adminProgressTimer);
    adminProgressTimer = null;

    if (!root || !bar) {
        return;
    }

    root.classList.add("is-finishing");
    setAdminProgressWidth(100);
    window.setTimeout(() => {
        bar.style.opacity = "0";
        window.setTimeout(() => {
            root.hidden = true;
            root.setAttribute("aria-hidden", "true");
            root.classList.remove("is-finishing");
            bar.style.transition = "none";
            setAdminProgressWidth(0);
            bar.style.opacity = "1";
            bar.style.transition = "";
        }, 220);
    }, 160);
};

const playFlasherFrom = (doc) => {
    const source = doc.querySelector("script.flasher-js");
    if (!source?.textContent) {
        return;
    }

    const flasher = window.flasher;
    if (!flasher || typeof flasher.render !== "function") {
        const run = document.createElement("script");
        run.className = "flasher-js";
        run.textContent = source.textContent;
        document.body.appendChild(run);
        return;
    }

    const text = source.textContent;
        const token = "options.push(";
        const start = text.lastIndexOf(token);
        if (start === -1) {
            return;
        }

        let index = start + token.length;
        while (index < text.length && /\s/.test(text[index])) {
            index += 1;
        }
        if (text[index] !== "{") {
            return;
        }

        let depth = 0;
        let end = index;
        for (; end < text.length; end += 1) {
            const char = text[end];
            if (char === "{") {
                depth += 1;
            } else if (char === "}") {
                depth -= 1;
                if (depth === 0) {
                    end += 1;
                    break;
                }
            } else if (char === '"' || char === "'") {
                const quote = char;
                end += 1;
                while (end < text.length && text[end] !== quote) {
                    if (text[end] === "\\") {
                        end += 1;
                    }
                    end += 1;
                }
            }
        }

        try {
            flasher.render(JSON.parse(text.slice(index, end)));
        } catch {
            // تجاهل إشعار تالف
        }
};

const syncSidebarActive = (url) => {
    const parsed = new URL(url, window.location.origin);
    const currentPath = parsed.pathname.replace(/\/+$/, "") || "/";
    const currentTab = parsed.searchParams.get("tab") || "app";

    document.querySelectorAll(".admin-sidebar a.nav-link").forEach((link) => {
        const linkUrl = new URL(link.href, window.location.origin);
        const path = linkUrl.pathname.replace(/\/+$/, "") || "/";
        const linkTab = linkUrl.searchParams.get("tab");
        let isActive = false;

        if (linkTab !== null) {
            isActive = currentPath === path && currentTab === linkTab;
        } else {
            const isDashboard = /\/admin$/.test(path);
            isActive = isDashboard
                ? currentPath === path
                : currentPath === path || currentPath.startsWith(`${path}/`);
        }

        link.classList.toggle("active", isActive);
    });

    document.querySelectorAll("[data-nav-group]").forEach((group) => {
        const hasActiveChild = !!group.querySelector("a.nav-link.active");
        group.classList.toggle("is-active", hasActiveChild);
        if (hasActiveChild) {
            group.classList.add("is-open");
        }
        const toggle = group.querySelector("[data-nav-group-toggle]");
        toggle?.classList.toggle("is-parent-active", hasActiveChild);
        toggle?.classList.remove("active");
        toggle?.setAttribute("aria-expanded", group.classList.contains("is-open") ? "true" : "false");
    });
};

const applyAdminDocument = (doc, url, { historyMode = "none" } = {}) => {
    const currentMain = document.querySelector(".admin-content");
    const nextMain = doc.querySelector(".admin-content");
    if (!currentMain || !nextMain) {
        window.location.assign(url);
        return false;
    }

    currentMain.innerHTML = nextMain.innerHTML;
    document.title = doc.title || document.title;

    const nextTop = doc.querySelector(".topbar-title div");
    const currentTop = document.querySelector(".topbar-title div");
    if (nextTop && currentTop) {
        currentTop.textContent = nextTop.textContent;
    }

    syncSidebarActive(url);

    const nextCsrf = doc.querySelector('meta[name="csrf-token"]')?.getAttribute("content");
    if (nextCsrf) {
        document.querySelector('meta[name="csrf-token"]')?.setAttribute("content", nextCsrf);
        document.querySelectorAll('input[name="_token"]').forEach((input) => {
            input.value = nextCsrf;
        });
        if (window.axios) {
            window.axios.defaults.headers.common["X-CSRF-TOKEN"] = nextCsrf;
        }
    }

    document.querySelectorAll("[data-color-sync]").forEach(syncColorLabel);
    document.querySelectorAll("[data-link-type]").forEach(syncLinkPanels);
    bindHomeSectionBackgroundToggle();
    document.querySelectorAll(".modal-backdrop").forEach((el) => el.remove());
    document.body.classList.remove("modal-open");
    document.body.style.removeProperty("overflow");
    document.body.style.removeProperty("padding-right");
    window.dispatchEvent(new Event("admin:content-ready"));

    if (historyMode === "push") {
        history.pushState({ ajaxAdmin: true }, "", url);
    } else if (historyMode === "replace") {
        history.replaceState({ ajaxAdmin: true }, "", url);
    }

    playFlasherFrom(doc);
    return true;
};

const swapAdminContent = async (url, { push = true, silent = false } = {}) => {
    if (adminMutating) {
        return;
    }

    const currentMain = document.querySelector(".admin-content");
    if (!currentMain) {
        window.location.assign(url);
        return;
    }

    ajaxController?.abort();
    ajaxController = new AbortController();
    if (!silent) {
        startAdminProgress();
    }
    const scrollY = window.scrollY;
    const sidebarNav = document.querySelector(".sidebar-nav");
    const sidebarScroll = sidebarNav?.scrollTop ?? 0;

    try {
        const response = await fetch(url, {
            signal: ajaxController.signal,
            headers: {
                "X-Requested-With": "XMLHttpRequest",
                Accept: "text/html",
            },
            credentials: "same-origin",
        });
        if (response.status === 419) {
            window.location.assign("/admin/login");
            return;
        }
        if (!response.ok) {
            window.location.assign(url);
            return;
        }

        const doc = new DOMParser().parseFromString(await response.text(), "text/html");
        if (!applyAdminDocument(doc, response.url || url, { historyMode: push ? "push" : "none" })) {
            return;
        }

        window.scrollTo(0, scrollY);
        if (sidebarNav) {
            sidebarNav.scrollTop = sidebarScroll;
        }
    } catch (error) {
        if (error?.name === "AbortError") {
            return;
        }
        window.location.assign(url);
    } finally {
        if (!silent) {
            finishAdminProgress();
        }
    }
};

const submitAdminForm = async (form, submitter) => {
    const currentMain = document.querySelector(".admin-content");
    if (!currentMain) {
        form.submit();
        return;
    }

    adminMutating = true;
    ajaxController?.abort();
    startAdminProgress();
    if (submitter) {
        submitter.disabled = true;
    }
    const sidebarNav = document.querySelector(".sidebar-nav");
    const sidebarScroll = sidebarNav?.scrollTop ?? 0;

    const formData = new FormData(form);
    if (submitter?.name && !formData.has(submitter.name)) {
        formData.append(submitter.name, submitter.value ?? "");
    }
    const methodOverride = form.querySelector('input[name="_method"]')?.value;
    if (methodOverride) {
        formData.set("_method", methodOverride);
    }

    try {
        const response = await fetch(form.getAttribute("action") || window.location.href, {
            method: "POST",
            body: formData,
            credentials: "same-origin",
            headers: {
                Accept: "text/html",
            },
            redirect: "follow",
        });

        if (response.status === 419) {
            window.location.assign("/admin/login");
            return;
        }

        if (response.redirected && /\/login(?:\/|$|\?)/.test(new URL(response.url).pathname)) {
            window.location.assign(response.url);
            return;
        }

        const contentType = response.headers.get("content-type") || "";
        if (!contentType.includes("text/html")) {
            window.location.assign(response.url || window.location.href);
            return;
        }

        const doc = new DOMParser().parseFromString(await response.text(), "text/html");
        applyAdminDocument(doc, response.url || window.location.href, { historyMode: "replace" });
        if (sidebarNav) {
            sidebarNav.scrollTop = sidebarScroll;
        }
    } catch {
        form.submit();
    } finally {
        adminMutating = false;
        finishAdminProgress();
        if (submitter) {
            submitter.disabled = false;
        }
    }
};

document.addEventListener("click", (event) => {
    if (isModifiedClick(event)) {
        return;
    }

    const sidebarLink = event.target.closest(".admin-sidebar a.nav-link[href]");
    if (sidebarLink && sidebarLink.target !== "_blank") {
        const href = sidebarLink.getAttribute("href");
        if (href && href !== "#" && !href.startsWith("javascript:")) {
            const url = new URL(sidebarLink.href, window.location.origin);
            if (url.origin === window.location.origin) {
                event.preventDefault();
                if (!desktopQuery.matches) {
                    closeMobileSidebar();
                }
                swapAdminContent(url.toString());
                return;
            }
        }
    }

    const link = event.target.closest(".simple-pager a[href], .pagination a[href]");
    if (!link || link.target === "_blank") {
        return;
    }
    const href = link.getAttribute("href");
    if (!href || href === "#") {
        return;
    }

    event.preventDefault();
    swapAdminContent(link.href);
});

document.addEventListener("submit", (event) => {
    const form = event.target;
    if (!(form instanceof HTMLFormElement) || !form.closest(".admin-content")) {
        return;
    }
    if (event.defaultPrevented || form.target === "_blank") {
        return;
    }

    const method = (form.getAttribute("method") || "get").toLowerCase();
    event.preventDefault();

    if (method === "get") {
        const url = new URL(form.getAttribute("action") || window.location.href, window.location.origin);
        url.search = "";
        new FormData(form).forEach((value, key) => {
            if (String(value).trim() !== "") {
                url.searchParams.append(key, String(value));
            }
        });
        swapAdminContent(url.toString());
        return;
    }

    submitAdminForm(form, event.submitter instanceof HTMLElement ? event.submitter : null);
});

window.addEventListener("popstate", () => {
    swapAdminContent(window.location.href, { push: false });
});

const currency = "\u20C1";

const formatMoney = (value) =>
    `${Number(value).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })} ${currency}`;

const refreshOrderLine = (row) => {
    const price = Number(row.dataset.price || 0);
    const qty = Number(row.querySelector("[data-order-qty-input], [data-qty-input]")?.value || 0);
    const cell = row.querySelector("[data-line-total]");
    if (cell) {
        cell.textContent = formatMoney(price * qty);
    }
};

const syncOrderEmptyState = (editor) => {
    const empty = editor.querySelector("[data-order-empty]");
    const rows = editor.querySelectorAll("[data-order-items] tbody tr");
    if (empty) {
        empty.hidden = rows.length > 0;
    }
};

const setOrderChipActive = (buttons, selected) => {
    buttons.forEach((btn) => {
        const on = btn === selected;
        btn.classList.toggle("btn-brand", on);
        btn.classList.toggle("btn-outline-success", !on);
    });
};

const filterOrderCatalog = (catalog) => {
    const term = (catalog.querySelector("[data-order-product-search]")?.value || "").trim().toLowerCase();
    const activeRoot = catalog.querySelector("[data-order-cat-root].btn-brand");
    const activeChild = catalog.querySelector("[data-order-children] [data-order-cat].btn-brand");
    const rootId = activeRoot?.dataset.orderCat || "";
    const childId = activeChild?.dataset.orderCat || "";
    let visible = 0;

    catalog.querySelectorAll("[data-order-product-card]").forEach((card) => {
        const name = (card.dataset.name || "").toLowerCase();
        const matchesSearch = term === "" || name.includes(term);
        let matchesCat = true;
        if (childId) {
            matchesCat = String(card.dataset.categoryId || "") === childId;
        } else if (rootId) {
            matchesCat =
                String(card.dataset.categoryRoot || "") === rootId ||
                String(card.dataset.categoryId || "") === rootId;
        }
        const show = matchesSearch && matchesCat;
        card.hidden = !show;
        if (show) {
            visible += 1;
        }
    });

    const empty = catalog.querySelector("[data-order-catalog-empty]");
    if (empty) {
        empty.hidden = visible > 0;
    }
};

const showOrderChildCats = (catalog, rootId) => {
    const row = catalog.querySelector("[data-order-children]");
    if (!row) {
        return;
    }
    let any = false;
    row.querySelectorAll("[data-order-cat]").forEach((btn) => {
        const match = rootId !== "" && String(btn.dataset.orderParent || "") === rootId;
        btn.hidden = !match;
        btn.classList.add("btn-outline-success");
        btn.classList.remove("btn-brand");
        if (match) {
            any = true;
        }
    });
    row.hidden = !any;
};

const productFromCard = (card) => ({
    id: card?.dataset.id,
    name: card?.dataset.name,
    price: card?.dataset.price,
    stock: card?.dataset.stock,
});

const orderQtyFor = (editor, productId) => {
    const input = editor?.querySelector(
        `tr[data-product-id="${productId}"] [data-order-qty-input], tr[data-product-id="${productId}"] [data-qty-input]`,
    );
    return Number(input?.value || 0);
};

const syncCardQtyDisplays = (editor) => {
    editor?.querySelectorAll("[data-order-product-card]").forEach((card) => {
        const qty = orderQtyFor(editor, card.dataset.id);
        const stock = Number(card.dataset.stock || 0);
        const label = card.querySelector("[data-order-card-qty]");
        const minus = card.querySelector("[data-order-card-minus]");
        const plus = card.querySelector("[data-order-card-plus]");
        if (label) {
            label.textContent = String(qty);
        }
        card.classList.toggle("is-in-order", qty > 0);
        if (minus) {
            minus.disabled = qty < 1;
        }
        if (plus) {
            plus.disabled = stock < 1 || qty >= stock;
        }
    });
};

const addProductToOrder = (editor, product, qty, options = {}) => {
    const template = document.getElementById("order-item-row");
    const body = editor?.querySelector("[data-order-items] tbody");
    if (!editor || !template || !body || !product?.id) {
        return false;
    }

    const productId = String(product.id);
    const name = product.name || "";
    const price = Number(product.price || 0);
    const stock = Number(product.stock || 0);
    const amount = Math.max(1, Number(qty || 1));
    const existing = body.querySelector(`tr[data-product-id="${productId}"]`);

    if (stock < 1 && !existing) {
        window.alert("هذا المنتج غير متوفر حالياً.");
        return false;
    }

    if (existing) {
        const input = existing.querySelector("[data-order-qty-input], [data-qty-input]");
        const next = Math.min(Math.max(1, stock), Number(input.value || 0) + amount);
        input.value = String(next);
        refreshOrderLine(existing);
        if (options.scroll) {
            existing.scrollIntoView({ behavior: "smooth", block: "nearest" });
        }
        syncCardQtyDisplays(editor);
        return true;
    }

    const row = template.content.firstElementChild.cloneNode(true);
    row.dataset.productId = productId;
    row.dataset.price = String(price);
    row.querySelector("[data-name]").textContent = name;
    const idInput = row.querySelector("[data-id-input]");
    idInput.name = `items[${productId}][product_id]`;
    idInput.value = productId;
    row.querySelector("[data-unit]").textContent = formatMoney(price);
    const rowQty = row.querySelector("[data-qty-input]");
    rowQty.name = `items[${productId}][quantity]`;
    rowQty.max = String(Math.max(1, stock));
    rowQty.value = String(Math.min(amount, Math.max(1, stock)));
    rowQty.setAttribute("data-order-qty-input", "");
    body.append(row);
    refreshOrderLine(row);
    syncOrderEmptyState(editor);
    if (options.scroll) {
        row.scrollIntoView({ behavior: "smooth", block: "nearest" });
    }
    syncCardQtyDisplays(editor);
    return true;
};

const decreaseProductFromOrder = (editor, productId) => {
    const body = editor?.querySelector("[data-order-items] tbody");
    const existing = body?.querySelector(`tr[data-product-id="${productId}"]`);
    if (!editor || !existing) {
        return false;
    }

    const input = existing.querySelector("[data-order-qty-input], [data-qty-input]");
    const next = Number(input?.value || 0) - 1;
    if (next < 1) {
        const rows = body.querySelectorAll("tr");
        if (rows.length <= 1) {
            window.alert("يجب أن يبقى منتج واحد على الأقل في الطلب.");
            return false;
        }
        existing.remove();
        syncOrderEmptyState(editor);
        syncCardQtyDisplays(editor);
        return true;
    }

    input.value = String(next);
    refreshOrderLine(existing);
    syncCardQtyDisplays(editor);
    return true;
};

const openOrderProductModal = (card) => {
    const modal = document.getElementById("orderProductModal");
    if (!modal) {
        return;
    }

    modal.dataset.id = card.dataset.id || "";
    modal.dataset.name = card.dataset.name || "";
    modal.dataset.price = card.dataset.price || "0";
    modal.dataset.stock = card.dataset.stock || "0";

    setText(modal.querySelector("[data-pick-title]"), card.dataset.name || "تفاصيل المنتج");
    const hero = modal.querySelector("[data-pick-hero]");
    const image = modal.querySelector("[data-pick-image]");
    if (hero && image) {
        if (card.dataset.image) {
            image.src = card.dataset.image;
            image.alt = card.dataset.name || "";
            hero.hidden = false;
        } else {
            image.removeAttribute("src");
            hero.hidden = true;
        }
    }

    const badges = modal.querySelector("[data-pick-badges]");
    if (badges) {
        badges.replaceChildren();
        [card.dataset.categoryName, card.dataset.sku ? `الرمز: ${card.dataset.sku}` : ""]
            .filter(Boolean)
            .forEach((label) => {
                const badge = document.createElement("span");
                badge.className = "badge badge-soft";
                badge.textContent = label;
                badges.append(badge);
            });
    }

    const description = modal.querySelector("[data-pick-description]");
    if (description) {
        const text = (card.dataset.description || "").trim();
        description.textContent = text;
        description.hidden = text === "";
    }

    const price = Number(card.dataset.price || 0);
    const original = Number(card.dataset.originalPrice || 0);
    const priceEl = modal.querySelector("[data-pick-price]");
    if (priceEl) {
        priceEl.textContent =
            original > price
                ? `${formatMoney(price)}  (بدلاً من ${formatMoney(original)})`
                : formatMoney(price);
    }
    setText(modal.querySelector("[data-pick-stock]"), card.dataset.stock || "0");

    const qty = modal.querySelector("[data-pick-qty]");
    const stock = Number(card.dataset.stock || 0);
    if (qty) {
        qty.value = "1";
        qty.max = String(Math.max(1, stock));
        qty.disabled = stock < 1;
    }
    const addBtn = modal.querySelector("[data-pick-add]");
    if (addBtn) {
        addBtn.disabled = stock < 1;
    }

    window.bootstrap.Modal.getOrCreateInstance(modal).show();
};

document.addEventListener("click", (event) => {
    const catBtn = event.target.closest("[data-order-cat]");
    if (catBtn) {
        event.preventDefault();
        const catalog = catBtn.closest("[data-order-catalog]");
        if (!catalog) {
            return;
        }
        if (catBtn.hasAttribute("data-order-cat-root")) {
            setOrderChipActive(catalog.querySelectorAll("[data-order-cat-root]"), catBtn);
            showOrderChildCats(catalog, catBtn.dataset.orderCat || "");
        } else {
            const already = catBtn.classList.contains("btn-brand");
            setOrderChipActive(
                catalog.querySelectorAll("[data-order-children] [data-order-cat]"),
                already ? null : catBtn,
            );
        }
        filterOrderCatalog(catalog);
        return;
    }

    const plus = event.target.closest("[data-order-card-plus]");
    if (plus) {
        event.preventDefault();
        const card = plus.closest("[data-order-product-card]");
        const editor = plus.closest("[data-order-editor]");
        addProductToOrder(editor, productFromCard(card), 1);
        return;
    }

    const minus = event.target.closest("[data-order-card-minus]");
    if (minus) {
        event.preventDefault();
        const card = minus.closest("[data-order-product-card]");
        const editor = minus.closest("[data-order-editor]");
        decreaseProductFromOrder(editor, card?.dataset.id);
        return;
    }

    const openCard = event.target.closest("[data-order-product-open]");
    if (openCard) {
        event.preventDefault();
        openOrderProductModal(openCard.closest("[data-order-product-card]"));
        return;
    }

    const pickAdd = event.target.closest("[data-pick-add]");
    if (pickAdd) {
        event.preventDefault();
        const modal = pickAdd.closest("#orderProductModal");
        const editor = document.querySelector("[data-order-editor]");
        const qty = Number(modal?.querySelector("[data-pick-qty]")?.value || 1);
        const added = addProductToOrder(editor, modal?.dataset || {}, qty, { scroll: true });
        if (added && modal) {
            window.bootstrap.Modal.getOrCreateInstance(modal).hide();
        }
        return;
    }

    const addBtn = event.target.closest("[data-order-add-item]");
    if (addBtn) {
        event.preventDefault();
        const editor = addBtn.closest("[data-order-editor]");
        const select = editor?.querySelector("[data-order-product]");
        const qtyInput = editor?.querySelector("[data-order-add-qty]");
        const option = select?.selectedOptions?.[0];
        if (!editor || !select || !option || !option.value) {
            return;
        }
        addProductToOrder(
            editor,
            {
                id: option.value,
                name: option.dataset.name || option.textContent.trim(),
                price: option.dataset.price,
                stock: option.dataset.stock,
            },
            qtyInput?.value,
        );
        select.value = "";
        if (qtyInput) {
            qtyInput.value = "1";
        }
        return;
    }

    const removeBtn = event.target.closest("[data-order-remove-item]");
    if (!removeBtn) {
        return;
    }
    event.preventDefault();
    const editor = removeBtn.closest("[data-order-editor]");
    const rows = editor?.querySelectorAll("[data-order-items] tbody tr") || [];
    if (rows.length <= 1) {
        window.alert("يجب أن يبقى منتج واحد على الأقل في الطلب.");
        return;
    }
    removeBtn.closest("tr")?.remove();
    if (editor) {
        syncOrderEmptyState(editor);
        syncCardQtyDisplays(editor);
    }
});

document.addEventListener("input", (event) => {
    const qty = event.target.closest("[data-order-qty-input], [data-qty-input]");
    if (qty) {
        refreshOrderLine(qty.closest("tr"));
        syncCardQtyDisplays(qty.closest("[data-order-editor]"));
    }

    const search = event.target.closest("[data-order-product-search]");
    if (!search) {
        return;
    }
    const catalog = search.closest("[data-order-catalog]");
    if (catalog) {
        filterOrderCatalog(catalog);
        return;
    }
    const editor = search.closest("[data-order-editor]");
    const select = editor?.querySelector("[data-order-product]");
    if (!select) {
        return;
    }
    const term = search.value.trim().toLowerCase();
    [...select.options].forEach((option, index) => {
        if (index === 0) {
            return;
        }
        const text = (option.dataset.pickerText || option.textContent || "").toLowerCase();
        option.hidden = term !== "" && !text.includes(term);
    });
});

const setFormField = (form, name, value) => {
    const el = form.querySelector(`[name="${name}"]`);
    if (!el) {
        return;
    }
    if (el.type === "checkbox") {
        el.checked = value === true || value === "1" || value === 1;
        return;
    }
    el.value = value ?? "";
};

const clearFormErrors = (form) => {
    form.querySelectorAll(".is-invalid").forEach((el) => el.classList.remove("is-invalid"));
    form.querySelectorAll(".invalid-feedback").forEach((el) => el.remove());
};

const setDeliveryFormMode = (form, id) => {
    const method = form.querySelector("[data-http-method]");
    const editing = form.querySelector("[data-editing-id]");
    const scope = form.closest(".modal") || form;
    const title = scope.querySelector("[data-rule-title], [data-perk-title], [data-phrase-title], [data-smart-title], [data-trending-title]");
    if (id) {
        form.action = `${String(form.dataset.updateBase || "").replace(/\/$/, "")}/${id}`;
        if (method) {
            method.value = "PUT";
        }
        if (editing) {
            editing.value = String(id);
        }
        if (title) {
            title.textContent = form.dataset.titleEdit || title.textContent;
        }
        return;
    }
    form.action = form.dataset.store || form.action;
    if (method) {
        method.value = "POST";
    }
    if (editing) {
        editing.value = "";
    }
    if (title) {
        title.textContent = form.dataset.titleCreate || title.textContent;
    }
};

const syncRulePricingUI = (root = document) => {
    root.querySelectorAll("[data-pricing-type]").forEach((select) => {
        const form = select.closest("form");
        if (!form) {
            return;
        }
        const type = select.value;
        const amountWrap = form.querySelector("[data-amount-wrap]");
        const modeWrap = form.querySelector("[data-mode-wrap]");
        if (amountWrap) {
            amountWrap.hidden = type === "free";
        }
        if (modeWrap) {
            modeWrap.hidden = type !== "per_km";
        }
    });
};

const syncPerkRewardUI = (root = document) => {
    root.querySelectorAll("[data-perk-reward]").forEach((select) => {
        const form = select.closest("form");
        const wrap = form?.querySelector("[data-perk-value-wrap]");
        if (wrap) {
            wrap.hidden = select.value === "free";
        }
    });
};

const resetRuleForm = (form) => {
    if (!form) {
        return;
    }
    clearFormErrors(form);
    setDeliveryFormMode(form, null);
    setFormField(form, "name", "");
    setFormField(form, "min_km", "0");
    setFormField(form, "max_km", "");
    setFormField(form, "pricing_type", "free");
    setFormField(form, "amount", "0");
    setFormField(form, "per_km_mode", "entire");
    setFormField(form, "sort_order", "0");
    setFormField(form, "is_active", "1");
    setFormField(form, "note", "");
    setFormField(form, "note_enabled", "0");
    syncRulePricingUI(form);
};

const fillRuleForm = (form, data) => {
    if (!form) {
        return;
    }
    clearFormErrors(form);
    setDeliveryFormMode(form, data.id);
    setFormField(form, "name", data.name || "");
    setFormField(form, "min_km", data.minKm ?? "0");
    setFormField(form, "max_km", data.maxKm ?? "");
    setFormField(form, "pricing_type", data.pricingType || "free");
    setFormField(form, "amount", data.amount ?? "0");
    setFormField(form, "per_km_mode", data.perKmMode || "entire");
    setFormField(form, "sort_order", data.sortOrder ?? "0");
    setFormField(form, "is_active", data.isActive);
    setFormField(form, "note", data.note || "");
    setFormField(form, "note_enabled", data.noteEnabled);
    syncRulePricingUI(form);
};

const resetPerkForm = (form) => {
    if (!form) {
        return;
    }
    clearFormErrors(form);
    setDeliveryFormMode(form, null);
    setFormField(form, "name", "");
    setFormField(form, "trigger_type", "min_orders");
    setFormField(form, "min_orders", "4");
    setFormField(form, "reward_type", "free");
    setFormField(form, "reward_value", "0");
    setFormField(form, "sort_order", "0");
    setFormField(form, "is_active", "1");
    syncPerkRewardUI(form);
};

const fillPerkForm = (form, data) => {
    if (!form) {
        return;
    }
    clearFormErrors(form);
    setDeliveryFormMode(form, data.id);
    setFormField(form, "name", data.name || "");
    setFormField(form, "trigger_type", data.triggerType || "min_orders");
    setFormField(form, "min_orders", data.minOrders ?? "4");
    setFormField(form, "reward_type", data.rewardType || "free");
    setFormField(form, "reward_value", data.rewardValue ?? "0");
    setFormField(form, "sort_order", data.sortOrder ?? "0");
    setFormField(form, "is_active", data.isActive);
    syncPerkRewardUI(form);
};

const fillSlotForm = (form, data = {}) => {
    if (!form) {
        return;
    }
    const id = data.id || data.editingId || "";
    const editing = form.querySelector("[data-editing-id]");
    if (editing) {
        editing.value = id;
    }
    const base = form.getAttribute("data-update-base") || "";
    if (id && base) {
        form.action = `${base.replace(/\/$/, "")}/${id}`;
    }
    const weekday = form.querySelector("[data-slot-weekday]");
    const start = form.querySelector("[data-slot-start]");
    const end = form.querySelector("[data-slot-end]");
    const sort = form.querySelector("[data-slot-sort]");
    const active = form.querySelector("[data-slot-active]");
    if (weekday) {
        weekday.value = String(data.weekday ?? "0");
    }
    if (start) {
        start.value = data.startTime || "10:00";
    }
    if (end) {
        end.value = data.endTime || "12:00";
    }
    if (sort) {
        sort.value = data.sortOrder ?? "0";
    }
    if (active) {
        active.checked = String(data.isActive ?? "1") === "1";
    }
    const interval = form.querySelector("[data-slot-interval]");
    if (interval) {
        interval.value = String(data.intervalMinutes ?? "15");
    }
};

const bindDeliveryPage = () => {
    syncRulePricingUI();
    syncPerkRewardUI();
    ["deliveryRuleModal", "deliveryPerkModal", "deliverySlotModal", "pickupSlotModal"].forEach((id) => {
        const modal = document.getElementById(id);
        if (modal?.dataset.open === "1") {
            window.bootstrap.Modal.getOrCreateInstance(modal).show();
        }
    });
};

document.addEventListener("change", (event) => {
    if (event.target.closest("[data-pricing-type]")) {
        syncRulePricingUI();
    }
    if (event.target.closest("[data-perk-reward]")) {
        syncPerkRewardUI();
    }
});

document.addEventListener("click", (event) => {
    if (!event.target.closest("#delivery_coords_apply")) {
        return;
    }
    const raw = (document.getElementById("delivery_coords_paste")?.value || "").trim();
    const match = raw.match(/(-?\d+(?:\.\d+)?)\s*[, ]\s*(-?\d+(?:\.\d+)?)/);
    if (!match) {
        window.alert("الصق الإحداثيات بهذا الشكل: 24.7136, 46.6753");
        return;
    }
    const lat = document.getElementById("delivery_store_lat");
    const lng = document.getElementById("delivery_store_lng");
    if (lat) {
        lat.value = match[1];
    }
    if (lng) {
        lng.value = match[2];
    }
});

document.addEventListener("show.bs.modal", (event) => {
    const modal = event.target;
    const trigger = event.relatedTarget;
    if (!(modal instanceof HTMLElement) || !(trigger instanceof HTMLElement)) {
        return;
    }
    if (modal.id === "deliveryRuleModal") {
        const form = modal.querySelector("#deliveryRuleForm");
        if (trigger.hasAttribute("data-delivery-rule-edit")) {
            fillRuleForm(form, trigger.dataset);
        } else if (trigger.hasAttribute("data-delivery-rule-create")) {
            resetRuleForm(form);
        }
        requestAnimationFrame(() => {
            const body = modal.querySelector(".modal-body");
            if (body) {
                body.scrollTop = 0;
            }
        });
        return;
    }
    if (modal.id === "deliveryPerkModal") {
        const form = modal.querySelector("#deliveryPerkForm");
        if (trigger.hasAttribute("data-delivery-perk-edit")) {
            fillPerkForm(form, trigger.dataset);
        } else if (trigger.hasAttribute("data-delivery-perk-create")) {
            resetPerkForm(form);
        }
        return;
    }
    if (modal.id === "deliverySlotModal") {
        const form = modal.querySelector("#deliverySlotForm");
        if (trigger.hasAttribute("data-delivery-slot-edit")) {
            fillSlotForm(form, trigger.dataset);
        }
        return;
    }
    if (modal.id === "pickupSlotModal") {
        const form = modal.querySelector("#pickupSlotForm");
        if (trigger.hasAttribute("data-pickup-slot-edit")) {
            fillSlotForm(form, trigger.dataset);
        }
    }
});

bindDeliveryPage();
window.addEventListener("admin:content-ready", bindDeliveryPage);

const escLive = (value) =>
    String(value ?? "")
        .replaceAll("&", "&amp;")
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;")
        .replaceAll('"', "&quot;");

const livePages = () => {
    const path = window.location.pathname.replace(/\/+$/, "");
    return (
        path.endsWith("/admin") ||
        path.includes("/admin/orders") ||
        path.includes("/admin/couriers")
    );
};

const liveBusy = () => {
    if (adminMutating || document.querySelector(".modal.show, .fl-container, .fl-wrapper")) {
        return true;
    }
    const active = document.activeElement;
    return Boolean(active && ["INPUT", "TEXTAREA", "SELECT"].includes(active.tagName));
};

const renderLiveList = (events) => {
    const list = document.querySelector("[data-live-list]");
    if (!list) {
        return;
    }
    if (!events.length) {
        list.innerHTML = '<p class="text-muted small mb-0 p-2">لا توجد تحديثات بعد.</p>';
        return;
    }
    list.innerHTML = events
        .map(
            (event) =>
                `<div class="live-bell-item"><strong>${escLive(event.title)}</strong><span>${escLive(event.body)}</span><small>${escLive(event.created_label || "")}</small></div>`,
        )
        .join("");
};

const setLiveCount = (count) => {
    const badge = document.querySelector("[data-live-count]");
    if (!badge) {
        return;
    }
    if (count > 0) {
        badge.hidden = false;
        badge.textContent = count > 9 ? "9+" : String(count);
    } else {
        badge.hidden = true;
    }
};

const pushLiveToast = (event) => {
    const stack = document.querySelector("[data-live-toasts]");
    if (!stack) {
        return;
    }
    const toast = document.createElement("div");
    toast.className = "live-toast";
    toast.innerHTML = `<strong>${escLive(event.title)}</strong><span>${escLive(event.body)}</span>`;
    stack.prepend(toast);
    setTimeout(() => toast.classList.add("is-out"), 4200);
    setTimeout(() => toast.remove(), 5000);
};

let liveStamp = null;
let liveLatestId = 0;

const pollLive = async () => {
    try {
        const { data } = await window.axios.get("/admin/live", {
            params: { after: liveLatestId },
        });
        renderLiveList(data.events || []);
        setLiveCount(data.unread || 0);

        if (liveLatestId > 0) {
            (data.fresh || []).forEach(pushLiveToast);
            if (data.stamp && data.stamp !== liveStamp && livePages() && !liveBusy()) {
                swapAdminContent(window.location.href, { push: false, silent: true });
            }
        }

        liveStamp = data.stamp || liveStamp;
        liveLatestId = data.latest_id || liveLatestId;
    } catch {
        // تجاهل فشل الشبكة المؤقت
    }
};

document.addEventListener("click", (event) => {
    const toggle = event.target.closest("[data-live-toggle]");
    if (toggle) {
        const menu = document.querySelector("[data-live-menu]");
        if (menu) {
            menu.hidden = !menu.hidden;
        }
        return;
    }
    if (!event.target.closest("[data-live-bell]")) {
        const menu = document.querySelector("[data-live-menu]");
        if (menu) {
            menu.hidden = true;
        }
    }
});

document.querySelector("[data-live-read]")?.addEventListener("click", async () => {
    try {
        await window.axios.post("/admin/live/read");
        setLiveCount(0);
    } catch {
        //
    }
});

pollLive();
setInterval(pollLive, 5000);

const settingsPickerCount = () => {
    const root = document.querySelector("[data-product-picker]");
    if (!root) {
        return;
    }
    const count = root.querySelectorAll(
        "[data-product-picker-item] input[type=checkbox]:checked",
    ).length;
    const label = root.querySelector("[data-product-picker-count]");
    if (label) {
        label.textContent = String(count);
    }
};

const syncSettingsScope = () => {
    const selected = document.querySelector(
        '[data-sold-scope][value="selected"]',
    )?.checked;
    const picker = document.querySelector("[data-product-picker]");
    if (picker) {
        picker.dataset.scope = selected ? "selected" : "all";
    }
};

document.addEventListener("submit", (event) => {
    const form = event.target.closest("[data-wipe-products-form]");
    if (!form) {
        return;
    }
    const phrase = (form.getAttribute("data-wipe-phrase") || "").trim();
    const typed = (form.querySelector("[data-wipe-products-input]")?.value || "").trim();
    if (typed !== phrase) {
        event.preventDefault();
        window.alert("اكتب «" + phrase + "» للتأكيد.");
        return;
    }
    if (!window.confirm(form.getAttribute("data-wipe-confirm") || "")) {
        event.preventDefault();
    }
});

document.addEventListener("input", (event) => {
    const search = event.target.closest("[data-product-picker-search]");
    if (!search) {
        return;
    }
    const query = search.value.trim().toLowerCase();
    document.querySelectorAll("[data-product-picker-item]").forEach((row) => {
        const name = (row.dataset.name || "").toLowerCase();
        row.hidden = query !== "" && !name.includes(query);
    });
});

document.addEventListener("change", (event) => {
    if (event.target.closest("[data-sold-scope]")) {
        syncSettingsScope();
    }
    if (event.target.closest("[data-product-picker-item]")) {
        settingsPickerCount();
    }
});

document.addEventListener("click", (event) => {
    if (event.target.closest("[data-product-picker-all]")) {
        document
            .querySelectorAll("[data-product-picker-item]:not([hidden]) input[type=checkbox]")
            .forEach((checkbox) => {
                checkbox.checked = true;
            });
        settingsPickerCount();
    }
    if (event.target.closest("[data-product-picker-none]")) {
        document
            .querySelectorAll("[data-product-picker-item]:not([hidden]) input[type=checkbox]")
            .forEach((checkbox) => {
                checkbox.checked = false;
            });
        settingsPickerCount();
    }
});

window.addEventListener("admin:content-ready", () => {
    syncSettingsScope();
    settingsPickerCount();
});

syncSettingsScope();
settingsPickerCount();

const bindProductAiCopy = (root = document) => {
    root.querySelectorAll("[data-product-ai-copy]").forEach((box) => {
        if (!(box instanceof HTMLElement) || box.dataset.bound === "1") {
            return;
        }
        box.dataset.bound = "1";

        const form = box.closest("form");
        const endpoint = box.dataset.endpoint;
        const status = box.querySelector("[data-ai-status]");
        const button = box.querySelector("[data-ai-generate]");
        if (!form || !endpoint) {
            return;
        }

        let timer = null;
        let successTimer = null;
        let lastName = "";
        let busy = false;

        const field = (name) => form.querySelector(`[name="${name}"]`);
        const aiField = (key) => box.querySelector(`[data-ai-field="${key}"]`);
        const empty = (el) => !el || String(el.value).trim() === "";
        const emptyOrZero = (el) => empty(el) || String(el.value).trim() === "0";
        const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

        const payload = () => ({
            name: field("name")?.value.trim() || "",
            category_id: field("category_id")?.value || "",
            description: field("description")?.value || "",
            weight_label: field("weight_label")?.value || "",
            quantity_label: field("quantity_label")?.value || "",
            piece_count: field("piece_count")?.value || "",
        });

        const localHints = (name) => {
            const hints = {
                weight_label: "",
                piece_count: null,
                quantity_label: "",
            };

            const weight = name.match(
                /(\d+(?:[.,]\d+)?)\s*(كيلو|كجم|كغ|kg|جرام|غرام|جم|g|مل|ml|لتر|ل|l)\b/i,
            );
            if (weight) {
                hints.weight_label = `${weight[1].replace(",", ".")} ${weight[2]}`;
            }

            const pieces =
                name.match(/(?:×|x)\s*(\d{1,3})\b/i) ||
                name.match(/(\d{1,3})\s*(?:حبة|حبات|قطعة|قطع|علبة|عبوة|كيس|أكياس)\b/u);
            if (pieces) {
                const count = Number.parseInt(pieces[1], 10);
                if (count >= 2 && count <= 9999) {
                    hints.piece_count = count;
                    hints.quantity_label = `العدد ${count}`;
                }
            } else if (hints.weight_label) {
                hints.quantity_label = hints.weight_label;
            }

            return hints;
        };

        const setStatus = (text, show = true, tone = "muted") => {
            if (!(status instanceof HTMLElement)) {
                return;
            }
            clearTimeout(successTimer);
            status.hidden = !show || !text;
            status.textContent = text || "";
            status.classList.remove("text-muted", "text-success", "text-danger");
            status.classList.add(
                tone === "success"
                    ? "text-success"
                    : tone === "danger"
                      ? "text-danger"
                      : "text-muted",
            );
        };

        const fillText = (el, value, overwrite) => {
            if (!el || value == null) {
                return false;
            }
            const text = String(value).trim();
            if (text === "" || (!overwrite && !empty(el))) {
                return false;
            }
            el.value = text;
            return true;
        };

        const fillNumber = (el, value, overwrite) => {
            if (!el || value == null || value === "") {
                return false;
            }
            if (!overwrite && !emptyOrZero(el)) {
                return false;
            }
            el.value = String(value);
            return true;
        };

        const applyLocalHints = (hints) => {
            fillText(field("weight_label"), hints.weight_label, false);
            fillNumber(field("piece_count"), hints.piece_count, false);
            fillText(field("quantity_label"), hints.quantity_label, false);
        };

        const applyCopy = (copy, force) => {
            const applied = [];

            if (fillText(field("description"), copy.description, force)) {
                applied.push("الوصف");
            }
            fillText(aiField("description"), copy.description, force);

            if (copy.category_id && empty(field("category_id"))) {
                const select = field("category_id");
                if (select) {
                    select.value = String(copy.category_id);
                    select.dispatchEvent(new Event("change", { bubbles: true }));
                    applied.push("التصنيف");
                }
            }

            if (fillNumber(field("price"), copy.price, false)) {
                applied.push("السعر");
            }
            if (fillNumber(field("stock"), copy.stock, false)) {
                applied.push("المخزون");
            }
            if (fillNumber(field("piece_count"), copy.piece_count, false)) {
                applied.push("عدد الحبات");
            }
            if (fillText(field("weight_label"), copy.weight_label, false)) {
                applied.push("الوزن");
            }
            if (fillText(field("quantity_label"), copy.quantity_label, false)) {
                applied.push("وصف الكمية");
            }
            if (fillText(aiField("benefits"), copy.benefits, force)) {
                applied.push("الفوائد");
            }
            if (fillText(aiField("keywords"), copy.keywords, force)) {
                applied.push("كلمات البحث");
            }
            if (fillText(aiField("usage_instructions"), copy.usage_instructions, force)) {
                applied.push("طريقة الاستخدام");
            }

            return applied;
        };

        const postCopy = async (data, attempt = 0) => {
            try {
                return await window.axios.post(endpoint, data, { timeout: 60000 });
            } catch (error) {
                const code = error?.response?.status;
                if (attempt < 1 && [502, 503, 504].includes(code)) {
                    setStatus("إعادة المحاولة...");
                    await sleep(900);
                    return postCopy(data, attempt + 1);
                }
                throw error;
            }
        };

        const generate = async (force = false) => {
            const data = payload();
            if (busy) {
                return;
            }
            if (data.name.length < 3) {
                if (force) {
                    setStatus("أدخل اسم المنتج أولاً (3 أحرف على الأقل).", true, "danger");
                }
                return;
            }

            busy = true;
            box.classList.add("is-busy");
            if (button instanceof HTMLButtonElement) {
                button.disabled = true;
            }
            setStatus("جاري التوليد...");

            applyLocalHints(localHints(data.name));

            try {
                const { data: copy } = await postCopy(data);
                const applied = applyCopy(copy, force);
                const textFields = force
                    ? ["الوصف", "الفوائد", "كلمات البحث", "طريقة الاستخدام"]
                    : applied;
                const suffix = copy?.meta?.cached ? " (سريع)" : "";
                const message =
                    textFields.length > 0
                        ? `تم التوليد: ${[...new Set(textFields)].join("، ")}${suffix}`
                        : `تم التوليد${suffix}`;
                setStatus(message, true, "success");
                successTimer = setTimeout(() => setStatus("", false), 4500);
            } catch (error) {
                const message =
                    error?.response?.data?.message || "تعذّر التوليد الآن.";
                setStatus(message, true, "danger");
            } finally {
                busy = false;
                box.classList.remove("is-busy");
                if (button instanceof HTMLButtonElement) {
                    button.disabled = false;
                }
            }
        };

        const schedule = () => {
            if (box.dataset.aiAuto === "0") {
                return;
            }
            const name = payload().name;
            if (name.length < 3 || name === lastName) {
                return;
            }
            lastName = name;
            clearTimeout(timer);
            timer = setTimeout(() => generate(false), 700);
        };

        if (box.dataset.aiAuto !== "0") {
            field("name")?.addEventListener("blur", schedule);
            field("category_id")?.addEventListener("change", () => {
                lastName = "";
                schedule();
            });
        }
        button?.addEventListener("click", () => generate(true));
    });
};

bindProductAiCopy();
window.addEventListener("admin:content-ready", () => bindProductAiCopy());

const bindBundleAiCopy = (root = document) => {
    root.querySelectorAll("[data-bundle-ai-copy]").forEach((box) => {
        if (!(box instanceof HTMLElement) || box.dataset.bound === "1") {
            return;
        }
        box.dataset.bound = "1";

        const form = box.closest("form");
        const endpoint = box.dataset.endpoint;
        const status = box.querySelector("[data-ai-status]");
        const button = box.querySelector("[data-ai-generate]");
        if (!form || !endpoint) {
            return;
        }

        let successTimer = null;
        let busy = false;

        const field = (name) => form.querySelector(`[name="${name}"]`);
        const aiField = (key) => box.querySelector(`[data-ai-field="${key}"]`);
        const empty = (el) => !el || String(el.value).trim() === "";
        const emptyOrZero = (el) => empty(el) || Number(el.value) === 0;

        const productNames = () =>
            [...form.querySelectorAll("[data-bundle-items-list] .bundle-item-meta strong")]
                .map((el) => el.textContent.trim())
                .filter(Boolean);

        const setStatus = (text, show = true, tone = "muted") => {
            if (!(status instanceof HTMLElement)) {
                return;
            }
            clearTimeout(successTimer);
            status.hidden = !show || !text;
            status.textContent = text || "";
            status.classList.remove("text-muted", "text-success", "text-danger");
            status.classList.add(
                tone === "success"
                    ? "text-success"
                    : tone === "danger"
                      ? "text-danger"
                      : "text-muted",
            );
        };

        const fillText = (el, value, overwrite) => {
            if (!el || value == null) {
                return false;
            }
            const text = String(value).trim();
            if (text === "" || (!overwrite && !empty(el))) {
                return false;
            }
            el.value = text;
            return true;
        };

        const fillNumber = (el, value, overwrite) => {
            if (!el || value == null || value === "") {
                return false;
            }
            if (!overwrite && !emptyOrZero(el)) {
                return false;
            }
            el.value = String(value);
            el.dispatchEvent(new Event("input", { bubbles: true }));
            el.dispatchEvent(new Event("change", { bubbles: true }));
            return true;
        };

        const generate = async () => {
            const name = field("name")?.value.trim() || "";
            if (busy) {
                return;
            }
            if (name.length < 3) {
                setStatus("أدخل اسم السلة أولاً (3 أحرف على الأقل).", true, "danger");
                return;
            }

            busy = true;
            box.classList.add("is-busy");
            if (button instanceof HTMLButtonElement) {
                button.disabled = true;
            }
            setStatus("جاري التوليد...");

            try {
                const { data: copy } = await window.axios.post(
                    endpoint,
                    {
                        name,
                        section_title: box.dataset.sectionTitle || "",
                        product_names: productNames(),
                    },
                    { timeout: 60000 },
                );

                const applied = [];
                if (fillText(aiField("summary") || field("summary"), copy.summary, true)) {
                    applied.push("الملخص");
                }
                if (fillText(aiField("description") || field("description"), copy.description, true)) {
                    applied.push("الوصف");
                }
                if (
                    fillNumber(
                        aiField("discount_percent") || field("discount_percent"),
                        copy.discount_percent,
                        false,
                    )
                ) {
                    applied.push("نسبة الخصم");
                }

                const suffix = copy?.meta?.cached ? " (سريع)" : "";
                setStatus(
                    applied.length > 0
                        ? `تم التوليد: ${applied.join("، ")}${suffix}`
                        : `تم التوليد${suffix}`,
                    true,
                    "success",
                );
                successTimer = setTimeout(() => setStatus("", false), 4500);
            } catch (error) {
                const message =
                    error?.response?.data?.message || "تعذّر التوليد الآن.";
                setStatus(message, true, "danger");
            } finally {
                busy = false;
                box.classList.remove("is-busy");
                if (button instanceof HTMLButtonElement) {
                    button.disabled = false;
                }
            }
        };

        button?.addEventListener("click", () => generate());
    });
};

bindBundleAiCopy();
window.addEventListener("admin:content-ready", () => bindBundleAiCopy());

const bindProductCopyBulk = (root = document) => {
    const panel = root.querySelector("[data-product-copy-bulk]");
    if (!(panel instanceof HTMLElement) || panel.dataset.bound === "1") {
        return;
    }
    panel.dataset.bound = "1";

    const statusUrl = panel.dataset.statusUrl;
    const chunkUrl = panel.dataset.chunkUrl;
    const cancelUrl = panel.dataset.cancelUrl;
    const confirmMessage = panel.dataset.confirm || "";
    const title = panel.querySelector("[data-bulk-title]");
    const count = panel.querySelector("[data-bulk-count]");
    const bar = panel.querySelector("[data-bulk-bar]");
    const detail = panel.querySelector("[data-bulk-detail]");
    const cancelBtn = panel.querySelector("[data-bulk-cancel]");
    const submit = root.querySelector("[data-product-copy-bulk-submit]");
    let processing = false;
    let stopRequested = false;

    const setSubmitBusy = (busy, label = "جاري البدء...") => {
        if (!(submit instanceof HTMLButtonElement)) {
            return;
        }
        if (!submit.dataset.originalLabel) {
            submit.dataset.originalLabel = submit.innerHTML;
        }
        submit.disabled = busy;
        submit.innerHTML = busy
            ? `<span class="spinner-border spinner-border-sm ms-1"></span> ${label}`
            : submit.dataset.originalLabel;
    };

    const render = (data) => {
        const total = Number(data.total || 0);
        const processed = Number(data.processed || 0);
        const ok = Number(data.ok || 0);
        const failed = Number(data.failed || 0);
        const skipped = Number(data.skipped || 0);
        const percent = Number(data.percent || 0);
        const running = Boolean(data.running);
        const finished = Boolean(data.finished_at);
        const cancelled = Boolean(data.cancelled);

        if (cancelled || (total === 0 && !running)) {
            panel.hidden = true;
            setSubmitBusy(false);
            if (cancelBtn instanceof HTMLButtonElement) {
                cancelBtn.hidden = true;
            }
            if (cancelled) {
                return;
            }
        }

        if (total > 0 && (running || finished)) {
            panel.hidden = false;
        } else if (!running) {
            panel.hidden = true;
        }

        if (count) {
            count.textContent = total > 0 ? `${processed} / ${total}` : "";
        }
        if (bar instanceof HTMLElement) {
            bar.style.width = `${Math.max(0, Math.min(100, percent))}%`;
            bar.setAttribute("aria-valuenow", String(percent));
        }

        if (cancelBtn instanceof HTMLButtonElement) {
            cancelBtn.hidden = !running;
            cancelBtn.disabled = false;
        }

        if (running) {
            if (title) {
                title.textContent = "جاري توليد المحتوى...";
            }
            if (detail) {
                const skippedNote =
                    skipped > 0 ? ` تم تخطي ${skipped} منتجاً مكتمل المحتوى.` : "";
                detail.textContent =
                    `يتم التوليد مباشرة من المتصفح. يمكنك متابعة التقدم هنا.${skippedNote}`;
            }
            setSubmitBusy(true, `جاري التوليد ${processed}/${total}`);
            return;
        }

        setSubmitBusy(false);

        if (total === 0) {
            panel.hidden = true;
            return;
        }

        if (title) {
            title.textContent = failed > 0 ? "اكتمل التوليد مع بعض الأخطاء" : "اكتمل توليد المحتوى";
        }
        if (detail) {
            const skippedNote =
                skipped > 0 ? ` تم تخطي ${skipped} منتجاً مكتمل المحتوى.` : "";
            detail.textContent =
                failed > 0
                    ? `تم توليد المحتوى لـ ${ok} منتج، وفشل ${failed}.${skippedNote}`
                    : `تم توليد المحتوى لـ ${ok} منتج.${skippedNote}`;
        }
    };

    const runChunks = async () => {
        if (processing || !chunkUrl) {
            return;
        }

        processing = true;
        stopRequested = false;

        try {
            while (!stopRequested) {
                const { data } = await window.axios.post(
                    chunkUrl,
                    {},
                    { timeout: 180000 },
                );
                render(data);

                if (!data.running) {
                    break;
                }
            }
        } catch (error) {
            const message =
                error?.response?.data?.message || "تعذّر متابعة التوليد. حاول مرة أخرى.";
            if (detail) {
                detail.textContent = message;
            }
            setSubmitBusy(false);
        } finally {
            processing = false;
        }
    };

    const form = root.querySelector("[data-product-copy-bulk-form]");
    form?.addEventListener("submit", async (event) => {
        event.preventDefault();

        if (confirmMessage && !window.confirm(confirmMessage)) {
            return;
        }

        setSubmitBusy(true);
        panel.hidden = false;

        try {
            const formData = new FormData(form);
            const { data } = await window.axios.post(form.action, formData, {
                headers: { Accept: "application/json" },
            });
            render(data);
            await runChunks();
        } catch (error) {
            const message =
                error?.response?.data?.message || "تعذّر بدء التوليد. حاول مرة أخرى.";
            if (detail) {
                detail.textContent = message;
            }
            panel.hidden = false;
            setSubmitBusy(false);
        }
    });

    cancelBtn?.addEventListener("click", async () => {
        if (!cancelUrl) {
            return;
        }
        if (!window.confirm("هل تريد إلغاء توليد المحتوى المتبقي؟")) {
            return;
        }

        stopRequested = true;

        if (cancelBtn instanceof HTMLButtonElement) {
            cancelBtn.disabled = true;
        }

        try {
            const { data } = await window.axios.post(cancelUrl);
            render(data);
            setSubmitBusy(false);
        } catch {
            if (cancelBtn instanceof HTMLButtonElement) {
                cancelBtn.disabled = false;
            }
        }
    });

    window.axios
        .get(statusUrl)
        .then(({ data }) => {
            render(data);
            if (data.running) {
                runChunks();
            }
        })
        .catch(() => {});
};

bindProductCopyBulk();
window.addEventListener("admin:content-ready", () => bindProductCopyBulk());

const selectedLookupIds = (root) =>
    [...root.querySelectorAll("[data-product-lookup-selected] [data-id]")]
        .map((chip) => Number(chip.dataset.id))
        .filter((id) => id > 0);

const lookupEmptyState = (root) => {
    const selected = root.querySelector("[data-product-lookup-selected]");
    if (!selected) {
        return;
    }
    selected.querySelector(".product-lookup-empty-state")?.remove();
    const hasChip = selected.querySelector("[data-id]");
    const allowEmpty = root.dataset.allowEmpty === "1";
    const multiple = root.dataset.multiple === "1";
    if (hasChip) {
        selected.querySelectorAll(`input[name="${root.dataset.name}"][value=""]`).forEach((input) => input.remove());
        return;
    }
    if (allowEmpty && !multiple) {
        const input = document.createElement("input");
        input.type = "hidden";
        input.name = root.dataset.name;
        input.value = "";
        selected.append(input);
        const hint = document.createElement("div");
        hint.className = "product-lookup-empty-state";
        hint.textContent = root.dataset.emptyLabel || "بدون اختيار";
        selected.append(hint);
    }
};

const lookupChip = (root, item) => {
    const chip = document.createElement("div");
    chip.className = "product-lookup-chip";
    chip.dataset.id = String(item.id);

    const input = document.createElement("input");
    input.type = "hidden";
    input.name = root.dataset.name;
    input.value = String(item.id);

    const copy = document.createElement("span");
    const title = document.createElement("strong");
    title.textContent = item.name || "";
    const meta = document.createElement("small");
    meta.textContent = [item.sku, item.price_label].filter(Boolean).join(" · ");
    copy.append(title, meta);

    const remove = document.createElement("button");
    remove.type = "button";
    remove.className = "product-lookup-remove";
    remove.setAttribute("data-product-lookup-remove", "");
    remove.setAttribute("aria-label", "إزالة");
    remove.innerHTML = '<i class="bi bi-x-lg"></i>';

    chip.append(input, copy, remove);
    return chip;
};

const addLookupItem = (root, item) => {
    if (!item?.id) {
        return;
    }
    const selected = root.querySelector("[data-product-lookup-selected]");
    if (!selected) {
        return;
    }
    const multiple = root.dataset.multiple === "1";
    if (!multiple) {
        selected.replaceChildren();
    } else if (selectedLookupIds(root).includes(Number(item.id))) {
        return;
    }
    selected.append(lookupChip(root, item));
    lookupEmptyState(root);
};

const renderLookupResults = (root, items) => {
    const box = root.querySelector("[data-product-lookup-results]");
    if (!box) {
        return;
    }
    box.replaceChildren();
    if (!items.length) {
        const empty = document.createElement("div");
        empty.className = "product-lookup-empty";
        empty.textContent = "لا توجد نتائج";
        box.append(empty);
        box.hidden = false;
        return;
    }
    items.forEach((item) => {
        const button = document.createElement("button");
        button.type = "button";
        button.className = "product-lookup-result";
        button.dataset.id = String(item.id);
        const title = document.createElement("strong");
        title.textContent = item.name || "";
        const meta = document.createElement("small");
        meta.textContent = [item.sku, item.barcode, item.price_label].filter(Boolean).join(" · ");
        button.append(title, meta);
        button.addEventListener("click", () => {
            addLookupItem(root, item);
            const search = root.querySelector("[data-product-lookup-q]");
            if (search) {
                search.value = "";
            }
            box.hidden = true;
            box.replaceChildren();
        });
        box.append(button);
    });
    box.hidden = false;
};

const searchLookup = async (root) => {
    const search = root.querySelector("[data-product-lookup-q]");
    const term = (search?.value || "").trim();
    const box = root.querySelector("[data-product-lookup-results]");
    if (term.length < 1) {
        if (box) {
            box.hidden = true;
            box.replaceChildren();
        }
        return;
    }

    const params = new URLSearchParams({
        q: term,
        exclude: selectedLookupIds(root).join(","),
    });
    if (root.dataset.except) {
        params.set("except", root.dataset.except);
    }
    if (root.dataset.giftOnly === "1") {
        params.set("gift_only", "1");
    }
    if (root.dataset.excludeGifts === "1") {
        params.set("exclude_gifts", "1");
    }

    try {
        const { data } = await window.axios.get(root.dataset.endpoint, { params });
        renderLookupResults(root, data.items || []);
    } catch {
        renderLookupResults(root, []);
    }
};

const bindProductLookups = () => {
    document.querySelectorAll("[data-product-lookup]").forEach((root) => {
        if (!(root instanceof HTMLElement) || root.dataset.bound === "1") {
            return;
        }
        root.dataset.bound = "1";
        lookupEmptyState(root);

        let timer = null;
        root.querySelector("[data-product-lookup-q]")?.addEventListener("input", () => {
            clearTimeout(timer);
            timer = setTimeout(() => searchLookup(root), 220);
        });

        root.addEventListener("click", (event) => {
            const remove = event.target.closest("[data-product-lookup-remove]");
            if (!remove) {
                return;
            }
            event.preventDefault();
            remove.closest("[data-id]")?.remove();
            lookupEmptyState(root);
        });
    });
};

document.addEventListener("click", (event) => {
    document.querySelectorAll("[data-product-lookup]").forEach((root) => {
        if (!root.contains(event.target)) {
            const box = root.querySelector("[data-product-lookup-results]");
            if (box) {
                box.hidden = true;
            }
        }
    });
});

bindProductLookups();
window.addEventListener("admin:content-ready", bindProductLookups);

const bundleExistingIds = (root) =>
    [...root.querySelectorAll("[data-bundle-items-list] [data-product-id]")]
        .map((row) => Number(row.dataset.productId))
        .filter((id) => id > 0);

const bundleReindex = (root) => {
    root.querySelectorAll("[data-bundle-items-list] .bundle-item-row").forEach((row, index) => {
        row.querySelectorAll("input[name]").forEach((input) => {
            input.name = input.name.replace(/items\[\d+]/, `items[${index}]`);
        });
    });
};

const bundleSyncEmpty = (root) => {
    const list = root.querySelector("[data-bundle-items-list]");
    const empty = root.querySelector("[data-bundle-items-empty]");
    const hasRows = list?.querySelector(".bundle-item-row");
    if (empty) {
        empty.hidden = Boolean(hasRows);
    }
};

const bundleSyncSummary = (root) => {
    const summary = root.querySelector("[data-bundle-items-summary]");
    const countEl = root.querySelector("[data-bundle-items-count]");
    const totalEl = root.querySelector("[data-bundle-items-total]");
    if (!summary || !countEl || !totalEl) {
        return;
    }

    let units = 0;
    let total = 0;
    root.querySelectorAll("[data-bundle-items-list] .bundle-item-row").forEach((row) => {
        const price = Number(row.dataset.price || 0);
        const qty = Number(row.querySelector("[data-bundle-qty-input]")?.value || 0);
        if (qty > 0) {
            units += qty;
            total += price * qty;
        }
    });

    if (units === 0) {
        summary.hidden = true;
        return;
    }

    summary.hidden = false;
    countEl.textContent = String(units);
    totalEl.textContent = total.toLocaleString("en-US", {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
    });
};

const bundleRowHtml = (item, index) => {
    const meta = [item.sku, item.price_label].filter(Boolean).join(" · ");
    const thumb = item.image_url
        ? `<img src="${escLive(item.image_url)}" alt="">`
        : '<i class="bi bi-box-seam"></i>';

    return `
        <article class="bundle-item-row is-new" data-product-id="${item.id}" data-price="${item.price ?? 0}">
            <input type="hidden" name="items[${index}][product_id]" value="${item.id}">
            <div class="bundle-item-thumb">${thumb}</div>
            <div class="bundle-item-meta">
                <strong>${escLive(item.name || "")}</strong>
                <small>${escLive(meta)}</small>
            </div>
            <div class="bundle-item-qty" data-bundle-qty>
                <button type="button" class="bundle-qty-btn" data-bundle-qty-minus aria-label="تقليل">−</button>
                <input type="number" min="1" max="99" name="items[${index}][quantity]" value="1" class="bundle-qty-input" data-bundle-qty-input aria-label="الكمية">
                <button type="button" class="bundle-qty-btn" data-bundle-qty-plus aria-label="زيادة">+</button>
            </div>
            <button type="button" class="bundle-item-remove" data-bundle-items-remove aria-label="إزالة">
                <i class="bi bi-trash3"></i>
            </button>
        </article>
    `;
};

const bundleAddItem = (root, item) => {
    if (!item?.id) {
        return;
    }
    if (bundleExistingIds(root).includes(Number(item.id))) {
        const existing = root.querySelector(`[data-product-id="${item.id}"]`);
        const input = existing?.querySelector("[data-bundle-qty-input]");
        if (input) {
            input.value = String(Math.min(99, Number(input.value || 0) + 1));
            existing?.classList.add("is-pulse");
            setTimeout(() => existing?.classList.remove("is-pulse"), 500);
        }
        bundleSyncSummary(root);
        return;
    }

    const list = root.querySelector("[data-bundle-items-list]");
    if (!list) {
        return;
    }

    const index = list.querySelectorAll(".bundle-item-row").length;
    list.insertAdjacentHTML("beforeend", bundleRowHtml(item, index));
    bundleReindex(root);
    bundleSyncEmpty(root);
    bundleSyncSummary(root);

    const row = list.querySelector(`[data-product-id="${item.id}"]`);
    row?.scrollIntoView({ behavior: "smooth", block: "nearest" });
    setTimeout(() => row?.classList.remove("is-new"), 700);
};

const bundleRenderResults = (root, items) => {
    const box = root.querySelector("[data-bundle-items-results]");
    if (!box) {
        return;
    }

    box.replaceChildren();
    if (!items.length) {
        const empty = document.createElement("div");
        empty.className = "product-lookup-empty";
        empty.textContent = "لا توجد نتائج";
        box.append(empty);
        box.hidden = false;
        return;
    }

    items.forEach((item) => {
        const button = document.createElement("button");
        button.type = "button";
        button.className = "product-lookup-result";
        button.dataset.id = String(item.id);
        const title = document.createElement("strong");
        title.textContent = item.name || "";
        const meta = document.createElement("small");
        meta.textContent = [item.sku, item.barcode, item.price_label].filter(Boolean).join(" · ");
        button.append(title, meta);
        button.addEventListener("click", () => {
            bundleAddItem(root, item);
            const search = root.querySelector("[data-bundle-items-q]");
            if (search) {
                search.value = "";
                search.focus();
            }
            box.hidden = true;
            box.replaceChildren();
        });
        box.append(button);
    });
    box.hidden = false;
};

const bundleSearch = async (root) => {
    const search = root.querySelector("[data-bundle-items-q]");
    const term = (search?.value || "").trim();
    const box = root.querySelector("[data-bundle-items-results]");
    if (term.length < 1) {
        if (box) {
            box.hidden = true;
            box.replaceChildren();
        }
        return;
    }

    const params = new URLSearchParams({
        q: term,
        exclude: bundleExistingIds(root).join(","),
    });

    try {
        const { data } = await window.axios.get(root.dataset.endpoint, { params });
        bundleRenderResults(root, data.items || []);
    } catch {
        bundleRenderResults(root, []);
    }
};

const bindBundleItemsEditors = () => {
    document.querySelectorAll("[data-bundle-items]").forEach((root) => {
        if (!(root instanceof HTMLElement) || root.dataset.bound === "1") {
            return;
        }
        root.dataset.bound = "1";

        let timer = null;
        const search = root.querySelector("[data-bundle-items-q]");

        search?.addEventListener("input", () => {
            clearTimeout(timer);
            timer = setTimeout(() => bundleSearch(root), 220);
        });

        search?.addEventListener("keydown", (event) => {
            if (event.key === "Escape") {
                const box = root.querySelector("[data-bundle-items-results]");
                if (box) {
                    box.hidden = true;
                    box.replaceChildren();
                }
                return;
            }
            if (event.key === "Enter") {
                event.preventDefault();
                const first = root.querySelector("[data-bundle-items-results] .product-lookup-result");
                first?.click();
            }
        });

        root.addEventListener("click", (event) => {
            const remove = event.target.closest("[data-bundle-items-remove]");
            if (remove) {
                event.preventDefault();
                remove.closest(".bundle-item-row")?.remove();
                bundleReindex(root);
                bundleSyncEmpty(root);
                bundleSyncSummary(root);
                return;
            }

            const minus = event.target.closest("[data-bundle-qty-minus]");
            if (minus) {
                event.preventDefault();
                const row = minus.closest(".bundle-item-row");
                const input = row?.querySelector("[data-bundle-qty-input]");
                if (input) {
                    input.value = String(Math.max(1, Number(input.value || 1) - 1));
                    bundleSyncSummary(root);
                }
                return;
            }

            const plus = event.target.closest("[data-bundle-qty-plus]");
            if (plus) {
                event.preventDefault();
                const row = plus.closest(".bundle-item-row");
                const input = row?.querySelector("[data-bundle-qty-input]");
                if (input) {
                    input.value = String(Math.min(99, Number(input.value || 1) + 1));
                    bundleSyncSummary(root);
                }
            }
        });

        root.addEventListener("input", (event) => {
            if (event.target.closest("[data-bundle-qty-input]")) {
                bundleSyncSummary(root);
            }
        });

        bundleSyncEmpty(root);
        bundleSyncSummary(root);
    });
};

document.addEventListener("click", (event) => {
    document.querySelectorAll("[data-bundle-items]").forEach((root) => {
        if (!root.contains(event.target)) {
            const box = root.querySelector("[data-bundle-items-results]");
            if (box) {
                box.hidden = true;
            }
        }
    });
});

bindBundleItemsEditors();
window.addEventListener("admin:content-ready", bindBundleItemsEditors);

const syncHomeSectionContentType = () => {
    const selected = document.querySelector('input[name="content_type"]:checked');
    if (!selected) {
        return;
    }
    const isBundle = selected.value === "bundles";
    const productsWrap = document.getElementById("home-section-products-wrap");
    const bundlesHint = document.getElementById("home-section-bundles-hint");
    if (productsWrap) {
        productsWrap.hidden = isBundle;
    }
    if (bundlesHint) {
        bundlesHint.hidden = !isBundle;
    }
};

const bindHomeSectionContentType = () => {
    const radios = document.querySelectorAll('input[name="content_type"]');
    if (!radios.length || document.body.dataset.homeSectionContentTypeBound === "1") {
        return;
    }
    document.body.dataset.homeSectionContentTypeBound = "1";
    syncHomeSectionContentType();
    radios.forEach((radio) => {
        radio.addEventListener("change", syncHomeSectionContentType);
    });
};

bindHomeSectionContentType();
window.addEventListener("admin:content-ready", bindHomeSectionContentType);

const bindHomeSectionLayoutReset = () => {
    document.querySelectorAll("[data-home-section-layout-reset]").forEach((button) => {
        if (button.dataset.homeSectionLayoutResetBound === "1") {
            return;
        }
        button.dataset.homeSectionLayoutResetBound = "1";
        button.addEventListener("click", () => {
            const defaults = {
                title_font_size: button.dataset.defaultTitleFontSize ?? "",
                subtitle_font_size: button.dataset.defaultSubtitleFontSize ?? "",
                card_width: button.dataset.defaultCardWidth ?? "",
                row_height: "",
                item_spacing: button.dataset.defaultItemSpacing ?? "",
                padding_top: button.dataset.defaultPaddingTop ?? "",
                padding_bottom: button.dataset.defaultPaddingBottom ?? "",
            };
            Object.entries(defaults).forEach(([name, value]) => {
                const input = document.querySelector(`[data-layout-field="${name}"]`);
                if (input) {
                    input.value = value;
                }
            });
        });
    });
};

bindHomeSectionLayoutReset();
window.addEventListener("admin:content-ready", bindHomeSectionLayoutReset);

const syncHomeSectionColorToggle = (checkbox) => {
    const target = document.querySelector(checkbox.dataset.homeSectionColorToggle);
    if (!target) {
        return;
    }
    const useDefault = checkbox.checked;
    target.disabled = useDefault;
    target.classList.toggle("opacity-50", useDefault);
};

const bindHomeSectionColorToggle = () => {
    document.querySelectorAll("[data-home-section-color-toggle]").forEach((checkbox) => {
        if (checkbox.dataset.homeSectionColorBound === "1") {
            return;
        }
        checkbox.dataset.homeSectionColorBound = "1";
        syncHomeSectionColorToggle(checkbox);
        checkbox.addEventListener("change", () => syncHomeSectionColorToggle(checkbox));
    });
};

const syncHomeSectionBackgroundMode = () => {
    const mode = document.querySelector('input[name="background_mode"]:checked')?.value || "color";
    const colorWrap = document.getElementById("home-section-bg-color-wrap");
    const imageWrap = document.getElementById("home-section-bg-image-wrap");
    if (colorWrap) {
        colorWrap.hidden = mode !== "color";
    }
    if (imageWrap) {
        imageWrap.hidden = mode !== "image";
    }
};

const bindHomeSectionBackgroundMode = () => {
    document.querySelectorAll("[data-home-section-bg-mode]").forEach((input) => {
        if (input.dataset.homeSectionBgModeBound === "1") {
            return;
        }
        input.dataset.homeSectionBgModeBound = "1";
        input.addEventListener("change", syncHomeSectionBackgroundMode);
    });
    syncHomeSectionBackgroundMode();
};

bindHomeSectionColorToggle();
window.addEventListener("admin:content-ready", bindHomeSectionColorToggle);
bindHomeSectionBackgroundMode();
window.addEventListener("admin:content-ready", bindHomeSectionBackgroundMode);

const bindCategoryPicker = () => {
    document.querySelectorAll("[data-category-picker]").forEach((grid) => {
        const root = grid.closest(".mb-3") || grid.parentElement;
        const search = root?.querySelector("[data-category-picker-q]");
        if (!search || search.dataset.bound === "1") {
            return;
        }
        search.dataset.bound = "1";
        search.addEventListener("input", () => {
            const term = search.value.trim().toLowerCase();
            grid.querySelectorAll("[data-category-picker-item]").forEach((item) => {
                const label = (item.dataset.label || "").toLowerCase();
                item.hidden = term !== "" && !label.includes(term);
            });
        });
    });
};

bindCategoryPicker();
window.addEventListener("admin:content-ready", bindCategoryPicker);

window.adminAddProductLookup = (root, item) => {
    const target = typeof root === "string" ? document.querySelector(root) : root;
    if (target instanceof HTMLElement) {
        addLookupItem(target, item);
    }
};

const clearGiftModalErrors = (form) => {
    if (!form) {
        return;
    }
    form.querySelectorAll("[data-gift-error]").forEach((node) => {
        node.textContent = "";
    });
    form.querySelectorAll("[data-gift-field]").forEach((field) => {
        field.classList.remove("is-invalid");
    });
    const alert = form.querySelector("[data-gift-form-error]");
    if (alert) {
        alert.hidden = true;
        alert.textContent = "";
    }
};

const resetGiftModal = (modal) => {
    const form = modal?.querySelector("#giftProductForm");
    if (!form) {
        return;
    }
    form.reset();
    clearGiftModalErrors(form);
    const stock = form.querySelector('[name="stock"]');
    if (stock) {
        stock.value = "10";
    }
    const price = form.querySelector('[name="price"]');
    if (price) {
        price.value = "0";
    }
    const mainPicker = modal.querySelector("[data-gift-main-picker] [data-product-lookup]");
    if (mainPicker instanceof HTMLElement) {
        const selected = mainPicker.querySelector("[data-product-lookup-selected]");
        selected?.replaceChildren();
        lookupEmptyState(mainPicker);
    }
};

const showGiftModalErrors = (form, payload) => {
    clearGiftModalErrors(form);
    const errors = payload?.errors || {};
    Object.entries(errors).forEach(([key, messages]) => {
        const message = Array.isArray(messages) ? messages[0] : String(messages || "");
        const field = form.querySelector(`[data-gift-field="${key}"]`);
        if (field) {
            field.classList.add("is-invalid");
        }
        const errorNode = form.querySelector(`[data-gift-error="${key}"]`);
        if (errorNode) {
            errorNode.textContent = message;
        }
    });
    const alert = form.querySelector("[data-gift-form-error]");
    if (alert && payload?.message) {
        alert.hidden = false;
        alert.textContent = payload.message;
    }
};

const bindGiftProductModal = () => {
    const modal = document.getElementById("giftProductModal");
    const form = modal?.querySelector("#giftProductForm");
    if (!(modal instanceof HTMLElement) || !(form instanceof HTMLFormElement) || form.dataset.bound === "1") {
        return;
    }
    form.dataset.bound = "1";

    modal.addEventListener("show.bs.modal", () => {
        resetGiftModal(modal);
        bindProductLookups();
    });

    form.addEventListener("submit", async (event) => {
        event.preventDefault();
        clearGiftModalErrors(form);

        const submit = form.querySelector("[data-gift-submit]");
        if (submit instanceof HTMLButtonElement) {
            submit.disabled = true;
        }

        const formData = new FormData(form);
        const currentId = Number(modal.dataset.currentProductId || 0);
        if (currentId > 0) {
            formData.set("current_product_id", String(currentId));
        }

        try {
            const { data } = await window.axios.post(modal.dataset.giftQuickEndpoint || "", formData, {
                headers: { "Content-Type": "multipart/form-data" },
            });

            const giftPicker = document.querySelector("[data-gift-product-picker] [data-product-lookup]");
            if (giftPicker instanceof HTMLElement) {
                addLookupItem(giftPicker, data);
            }

            window.bootstrap.Modal.getOrCreateInstance(modal).hide();
            resetGiftModal(modal);
        } catch (error) {
            const status = error?.response?.status;
            const payload = error?.response?.data || {};
            if (status === 422) {
                showGiftModalErrors(form, payload);
            } else {
                showGiftModalErrors(form, {
                    message: payload.message || "تعذّر حفظ منتج الهدية. حاول مرة أخرى.",
                });
            }
        } finally {
            if (submit instanceof HTMLButtonElement) {
                submit.disabled = false;
            }
        }
    });
};

bindGiftProductModal();
window.addEventListener("admin:content-ready", bindGiftProductModal);

const bindCouponForm = () => {
    const type = document.getElementById("coupon_type");
    const applies = document.getElementById("applies_to");
    if (!type || !applies) {
        return;
    }
    const sync = () => {
        const valueWrap = document.getElementById("value_wrap");
        const products = document.getElementById("products_wrap");
        const categories = document.getElementById("categories_wrap");
        if (valueWrap) {
            valueWrap.style.display = type.value === "free_shipping" ? "none" : "";
        }
        if (products) {
            products.style.display = applies.value === "products" ? "" : "none";
        }
        if (categories) {
            categories.style.display = applies.value === "categories" ? "" : "none";
        }
    };
    if (type.dataset.bound !== "1") {
        type.dataset.bound = "1";
        type.addEventListener("change", sync);
        applies.addEventListener("change", sync);
    }
    sync();
};

bindCouponForm();
window.addEventListener("admin:content-ready", bindCouponForm);

const resetDiscoveryForm = (form) => {
    if (!form) {
        return;
    }
    clearFormErrors(form);
    setDeliveryFormMode(form, null);
    setFormField(form, "phrase", "");
    setFormField(form, "sort_order", "0");
    setFormField(form, "is_active", "1");
};

const fillDiscoveryForm = (form, data) => {
    if (!form) {
        return;
    }
    clearFormErrors(form);
    setDeliveryFormMode(form, data.id);
    setFormField(form, "phrase", data.phrase || "");
    setFormField(form, "sort_order", data.sortOrder ?? "0");
    setFormField(form, "is_active", data.isActive);
};

const resetSearchPhraseForm = (form) => resetDiscoveryForm(form);

const fillSearchPhraseForm = (form, data) => fillDiscoveryForm(form, data);

const bindSearchPlaceholdersPage = () => {
    const phraseModal = document.getElementById("searchPhraseModal");
    if (phraseModal?.dataset.open === "1") {
        window.bootstrap.Modal.getOrCreateInstance(phraseModal).show();
    }
    const smartModal = document.getElementById("searchSmartModal");
    if (smartModal?.dataset.open === "1") {
        window.bootstrap.Modal.getOrCreateInstance(smartModal).show();
    }
    const trendingModal = document.getElementById("searchTrendingModal");
    if (trendingModal?.dataset.open === "1") {
        window.bootstrap.Modal.getOrCreateInstance(trendingModal).show();
    }
};

const renderCustomerSearchLogs = (name, logs) => {
    const title = document.querySelector("[data-customer-logs-title]");
    const body = document.querySelector("[data-customer-logs-body]");
    if (title) {
        title.textContent = name ? `كلمات بحث: ${name}` : "كلمات البحث";
    }
    if (!(body instanceof HTMLElement)) {
        return;
    }
    const rows = Array.isArray(logs) ? logs : [];
    if (rows.length === 0) {
        body.innerHTML = `<tr><td colspan="3" class="text-muted">لا توجد كلمات.</td></tr>`;
        return;
    }
    body.innerHTML = rows
        .map((row) => {
            const query = escLive(row.query || "");
            const date = escLive(row.date || "—");
            const product = row.found
                ? escLive(row.product || "منتج موجود")
                : '<span class="text-warning">غير موجود</span>';
            return `<tr><td class="fw-semibold">${query}</td><td>${date}</td><td>${product}</td></tr>`;
        })
        .join("");
};

document.addEventListener("show.bs.modal", (event) => {
    const modal = event.target;
    const trigger = event.relatedTarget;
    if (!(modal instanceof HTMLElement) || !(trigger instanceof HTMLElement)) {
        return;
    }
    if (modal.id === "searchPhraseModal") {
        const form = modal.querySelector("#searchPhraseForm");
        if (trigger.hasAttribute("data-search-phrase-edit")) {
            fillSearchPhraseForm(form, trigger.dataset);
        } else if (trigger.hasAttribute("data-search-phrase-create")) {
            resetSearchPhraseForm(form);
        }
        return;
    }
    if (modal.id === "searchSmartModal") {
        const form = modal.querySelector("#searchSmartForm");
        if (trigger.hasAttribute("data-search-smart-edit")) {
            fillDiscoveryForm(form, trigger.dataset);
        } else if (trigger.hasAttribute("data-search-smart-create")) {
            resetDiscoveryForm(form);
        }
        return;
    }
    if (modal.id === "searchTrendingModal") {
        const form = modal.querySelector("#searchTrendingForm");
        if (trigger.hasAttribute("data-search-trending-edit")) {
            fillDiscoveryForm(form, trigger.dataset);
        } else if (trigger.hasAttribute("data-search-trending-create")) {
            resetDiscoveryForm(form);
        }
        return;
    }
    if (modal.id === "customerSearchLogsModal" && trigger.hasAttribute("data-customer-search-logs")) {
        let logs = [];
        try {
            logs = JSON.parse(trigger.getAttribute("data-logs") || "[]");
        } catch (_) {
            logs = [];
        }
        renderCustomerSearchLogs(trigger.dataset.name || "", logs);
    }
});

bindSearchPlaceholdersPage();
window.addEventListener("admin:content-ready", bindSearchPlaceholdersPage);

const gccPhonePlaceholders = {
    966: "5XXXXXXXX",
    971: "5XXXXXXXX",
    965: "5XXXXXXX",
    973: "3XXXXXXX",
    974: "3XXXXXXX",
    968: "3XXXXXXX",
    967: "7XXXXXXXX",
};

const closeAllGccPhoneMenus = () => {
    document.querySelectorAll("[data-gcc-phone-menu]").forEach((menu) => {
        menu.hidden = true;
    });
    document.querySelectorAll("[data-gcc-phone-country-trigger]").forEach((trigger) => {
        trigger.setAttribute("aria-expanded", "false");
        trigger.closest(".gcc-phone-field")?.classList.remove("is-open");
    });
};

const setGccPhoneCountry = (field, code, flag, dial, placeholder) => {
    const hidden = field.querySelector("[data-gcc-phone-country-input]");
    const flagEl = field.querySelector("[data-gcc-phone-flag]");
    const dialEl = field.querySelector("[data-gcc-phone-dial]");
    const national = field.querySelector("[data-gcc-phone-national]");

    if (hidden) {
        hidden.value = code;
    }
    if (flagEl) {
        flagEl.textContent = flag;
    }
    if (dialEl) {
        dialEl.textContent = dial;
    }
    if (national) {
        national.placeholder = placeholder || gccPhonePlaceholders[code] || "XXXXXXXX";
    }

    field.querySelectorAll("[data-gcc-phone-option]").forEach((option) => {
        option.classList.toggle("is-active", option.dataset.code === code);
    });
};

const bindGccPhoneField = (field) => {
    if (field.dataset.gccPhoneBound === "1") {
        return;
    }
    field.dataset.gccPhoneBound = "1";

    const trigger = field.querySelector("[data-gcc-phone-country-trigger]");
    const menu = field.querySelector("[data-gcc-phone-menu]");
    const hidden = field.querySelector("[data-gcc-phone-country-input]");

    trigger?.addEventListener("click", (event) => {
        event.preventDefault();
        event.stopPropagation();
        const willOpen = menu?.hidden !== false;
        closeAllGccPhoneMenus();
        if (menu && willOpen) {
            menu.hidden = false;
            trigger.setAttribute("aria-expanded", "true");
            field.classList.add("is-open");
        }
    });

    field.querySelectorAll("[data-gcc-phone-option]").forEach((option) => {
        option.addEventListener("click", (event) => {
            event.preventDefault();
            event.stopPropagation();
            setGccPhoneCountry(
                field,
                option.dataset.code,
                option.dataset.flag,
                option.dataset.dial,
                option.dataset.placeholder,
            );
            closeAllGccPhoneMenus();
        });
    });

    if (hidden?.value) {
        const active = field.querySelector(`[data-gcc-phone-option][data-code="${hidden.value}"]`);
        if (active) {
            setGccPhoneCountry(
                field,
                active.dataset.code,
                active.dataset.flag,
                active.dataset.dial,
                active.dataset.placeholder,
            );
        }
    }
};

const bindGccPhoneInputs = () => {
    document.querySelectorAll("[data-gcc-phone-field]").forEach((field) => {
        bindGccPhoneField(field);
    });
};

document.addEventListener("click", closeAllGccPhoneMenus);
bindGccPhoneInputs();
window.addEventListener("admin:content-ready", bindGccPhoneInputs);

const reindexGccPhoneFieldNames = (row, countryName, nationalName) => {
    const field = row.querySelector("[data-gcc-phone-field]");
    if (!field) {
        return;
    }
    const hidden = field.querySelector("[data-gcc-phone-country-input]");
    const national = field.querySelector("[data-gcc-phone-national]");
    if (hidden) {
        hidden.name = countryName;
        hidden.removeAttribute("data-field");
    }
    if (national) {
        national.name = nationalName;
        national.removeAttribute("data-field");
    }
    field.dataset.gccPhoneBound = "0";
    bindGccPhoneField(field);
};

const reindexContactNumberRows = (list) => {
    list.querySelectorAll("[data-contact-number-row]").forEach((row, index) => {
        const nameInput = row.querySelector('[name*="[name]"], [data-field="name"]');
        if (nameInput) {
            nameInput.name = `customer_service_numbers[${index}][name]`;
            nameInput.removeAttribute("data-field");
        }
        reindexGccPhoneFieldNames(
            row,
            `customer_service_numbers[${index}][phone_country]`,
            `customer_service_numbers[${index}][phone]`,
        );
    });
};

const bindContactNumbersPicker = () => {
    document.querySelectorAll("[data-contact-numbers-picker]").forEach((root) => {
        if (root.dataset.contactNumbersBound === "1") {
            return;
        }
        root.dataset.contactNumbersBound = "1";

        const list = root.querySelector("[data-contact-numbers-list]");
        const template = root.querySelector("[data-contact-number-template]");
        const addBtn = root.querySelector("[data-contact-number-add]");
        if (!list || !template || !addBtn) {
            return;
        }

        addBtn.addEventListener("click", () => {
            const fragment = template.content.cloneNode(true);
            list.appendChild(fragment);
            reindexContactNumberRows(list);
        });

        list.addEventListener("click", (event) => {
            const removeBtn = event.target.closest("[data-contact-number-remove]");
            if (!removeBtn) {
                return;
            }
            const rows = list.querySelectorAll("[data-contact-number-row]");
            if (rows.length <= 1) {
                rows[0]?.querySelectorAll("input").forEach((input) => {
                    input.value = "";
                });
                return;
            }
            removeBtn.closest("[data-contact-number-row]")?.remove();
            reindexContactNumberRows(list);
        });
    });
};

bindContactNumbersPicker();
window.addEventListener("admin:content-ready", bindContactNumbersPicker);

const reindexOtpBypassPhoneRows = (list) => {
    list.querySelectorAll("[data-otp-bypass-phone-row]").forEach((row, index) => {
        reindexGccPhoneFieldNames(
            row,
            `otp_bypass_phones[${index}][country_code]`,
            `otp_bypass_phones[${index}][national]`,
        );
    });
};

const bindOtpBypassPhonesPicker = () => {
    document.querySelectorAll("[data-otp-bypass-phones-picker]").forEach((root) => {
        if (root.dataset.otpBypassPhonesBound === "1") {
            return;
        }
        root.dataset.otpBypassPhonesBound = "1";

        const list = root.querySelector("[data-otp-bypass-phones-list]");
        const template = root.querySelector("[data-otp-bypass-phone-template]");
        const addBtn = root.querySelector("[data-otp-bypass-phone-add]");
        if (!list || !template || !addBtn) {
            return;
        }

        addBtn.addEventListener("click", () => {
            const fragment = template.content.cloneNode(true);
            list.appendChild(fragment);
            reindexOtpBypassPhoneRows(list);
        });

        list.addEventListener("click", (event) => {
            const removeBtn = event.target.closest("[data-otp-bypass-phone-remove]");
            if (!removeBtn) {
                return;
            }
            const rows = list.querySelectorAll("[data-otp-bypass-phone-row]");
            if (rows.length <= 1) {
                rows[0]?.querySelectorAll("input").forEach((input) => {
                    input.value = "";
                });
                return;
            }
            removeBtn.closest("[data-otp-bypass-phone-row]")?.remove();
            reindexOtpBypassPhoneRows(list);
        });
    });
};

bindOtpBypassPhonesPicker();
window.addEventListener("admin:content-ready", bindOtpBypassPhonesPicker);

const bindPasswordPanels = () => {
    document.querySelectorAll("[data-password-panel]").forEach((panel) => {
        if (!(panel instanceof HTMLElement) || panel.dataset.passwordBound === "1") {
            return;
        }
        panel.dataset.passwordBound = "1";

        const currentInput = panel.querySelector("[data-current-password]");
        const newInput = panel.querySelector("[data-new-password]");
        const confirmInput = panel.querySelector("[data-password-confirm]");
        const currentStatus = panel.querySelector("[data-current-status]");
        const confirmStatus = panel.querySelector("[data-confirm-status]");
        const checklist = panel.querySelector("[data-password-checklist]");
        const verifyUrl = panel.dataset.verifyUrl;
        const evaluateUrl = panel.dataset.evaluateUrl;

        let verifyTimer = null;
        let evaluateTimer = null;

        const setStatus = (el, message, ok) => {
            if (!(el instanceof HTMLElement)) {
                return;
            }
            if (!message) {
                el.hidden = true;
                el.textContent = "";
                el.classList.remove("is-ok", "is-bad");
                return;
            }
            el.hidden = false;
            el.textContent = message;
            el.classList.toggle("is-ok", !!ok);
            el.classList.toggle("is-bad", !ok);
        };

        const syncConfirm = () => {
            const password = newInput?.value || "";
            const confirm = confirmInput?.value || "";
            if (!confirm) {
                setStatus(confirmStatus, "", false);
                return;
            }
            const ok = password === confirm;
            setStatus(
                confirmStatus,
                ok ? "التأكيد متطابق." : "التأكيد غير متطابق.",
                ok,
            );
        };

        const applyChecks = (checks) => {
            if (!(checklist instanceof HTMLElement)) {
                return;
            }
            checklist.hidden = false;
            checklist.querySelectorAll("[data-check]").forEach((item) => {
                const key = item.dataset.check;
                item.classList.toggle("is-ok", !!checks?.[key]);
                item.classList.toggle("is-bad", checks && !checks[key]);
            });
        };

        const verifyCurrent = async () => {
            if (!(currentInput instanceof HTMLInputElement) || !verifyUrl) {
                return;
            }
            const value = currentInput.value.trim();
            if (!value) {
                currentInput.classList.remove("is-valid", "is-invalid");
                setStatus(currentStatus, "", false);
                return;
            }
            try {
                const { data } = await window.axios.post(verifyUrl, {
                    current_password: value,
                });
                currentInput.classList.toggle("is-valid", !!data.ok);
                currentInput.classList.toggle("is-invalid", !data.ok);
                setStatus(currentStatus, data.message || "", !!data.ok);
            } catch {
                currentInput.classList.remove("is-valid");
                currentInput.classList.add("is-invalid");
                setStatus(currentStatus, "تعذر التحقق الآن.", false);
            }
        };

        const evaluatePassword = async () => {
            if (!(newInput instanceof HTMLInputElement)) {
                return;
            }
            const value = newInput.value;
            if (!value) {
                if (checklist) {
                    checklist.hidden = true;
                }
                newInput.classList.remove("is-valid", "is-invalid");
                syncConfirm();
                return;
            }

            const local = {
                length: value.length >= 8,
                letter: /\p{L}/u.test(value),
                number: /\d/u.test(value),
                symbol: /[^\p{L}\d\s]/u.test(value),
            };
            applyChecks(local);

            if (!evaluateUrl) {
                const ok = Object.values(local).every(Boolean);
                newInput.classList.toggle("is-valid", ok);
                newInput.classList.toggle("is-invalid", !ok);
                syncConfirm();
                return;
            }

            try {
                const { data } = await window.axios.post(evaluateUrl, { password: value });
                applyChecks(data.checks || local);
                newInput.classList.toggle("is-valid", !!data.ok);
                newInput.classList.toggle("is-invalid", !data.ok);
            } catch {
                const ok = Object.values(local).every(Boolean);
                newInput.classList.toggle("is-valid", ok);
                newInput.classList.toggle("is-invalid", !ok);
            }
            syncConfirm();
        };

        currentInput?.addEventListener("input", () => {
            clearTimeout(verifyTimer);
            verifyTimer = setTimeout(verifyCurrent, 450);
        });
        currentInput?.addEventListener("blur", verifyCurrent);

        newInput?.addEventListener("input", () => {
            clearTimeout(evaluateTimer);
            evaluateTimer = setTimeout(evaluatePassword, 250);
        });
        confirmInput?.addEventListener("input", syncConfirm);
    });
};

bindPasswordPanels();
window.addEventListener("admin:content-ready", bindPasswordPanels);

/* —— Reports hub —— */
const bindReportsHub = () => {
    const hub = document.getElementById("reportsHub");
    if (!hub || hub.dataset.bound === "1") {
        return;
    }
    hub.dataset.bound = "1";

    const state = {
        tab: hub.dataset.tab || "daily",
        preset: hub.dataset.preset || "today",
        from: hub.dataset.from,
        to: hub.dataset.to,
        currency: hub.dataset.currency || "",
        cache: {},
        orders: {
            page: 1,
            sort: "created_at",
            dir: "desc",
            q: "",
            status: "",
            per_page: 25,
        },
        client: {
            products: [],
            customers: [],
            couriers: [],
            inventory: [],
            coupons: [],
            sales: [],
        },
    };

    try {
        state.cache.overview = JSON.parse(hub.dataset.overview || "{}");
    } catch {
        state.cache.overview = {};
    }
    try {
        if (hub.dataset.daily) {
            state.cache.daily = JSON.parse(hub.dataset.daily);
        }
    } catch {
        state.cache.daily = null;
    }

    const money = (value) =>
        `${Number(value || 0).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })} ${state.currency}`;
    const num = (value) => Number(value || 0).toLocaleString("en-US");
    const esc = (value) =>
        String(value ?? "")
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;");

    const loadingEl = hub.querySelector("[data-report-loading]");
    const setLoading = (on) => {
        if (!loadingEl) return;
        loadingEl.hidden = !on;
    };

    const params = (extra = {}) => ({
        preset: state.preset,
        from: state.from,
        to: state.to,
        ...extra,
    });

    const queryString = (obj) =>
        new URLSearchParams(
            Object.entries(obj).filter(([, v]) => v !== null && v !== undefined && v !== ""),
        ).toString();

    const fetchSection = async (section, extra = {}) => {
        const key = `${section}:${JSON.stringify(extra)}:${state.from}:${state.to}`;
        if (state.cache[key]) {
            return state.cache[key];
        }
        setLoading(true);
        try {
            const { data } = await window.axios.get(hub.dataset.dataUrl, {
                params: params({ section, ...extra }),
            });
            state.cache[key] = data;
            return data;
        } finally {
            setLoading(false);
        }
    };

    const renderBars = (el, rows, valueKey = "count") => {
        if (!el) return;
        const max = Math.max(1, ...rows.map((r) => Number(r[valueKey] || 0)));
        if (!rows.length) {
            el.innerHTML = `<p class="text-muted small mb-0">لا بيانات.</p>`;
            return;
        }
        el.innerHTML = rows
            .map((row) => {
                const value = Number(row[valueKey] || 0);
                const width = Math.max(4, Math.round((value / max) * 100));
                return `<div class="reports-bar-row">
                    <strong>${esc(row.label)}</strong>
                    <div class="reports-bar-track"><div class="reports-bar-fill" style="width:${width}%"></div></div>
                    <span>${num(value)}</span>
                </div>`;
            })
            .join("");
    };

    const renderSalesChart = (el, series) => {
        if (!el) return;
        if (!series?.length) {
            el.innerHTML = `<p class="text-muted small mb-0">لا بيانات للفترة المحددة.</p>`;
            return;
        }
        const w = 640;
        const h = 220;
        const pad = { t: 16, r: 12, b: 28, l: 12 };
        const values = series.map((s) => Number(s.revenue || 0));
        const max = Math.max(1, ...values);
        const stepX = (w - pad.l - pad.r) / Math.max(1, series.length - 1);
        const points = series.map((s, i) => {
            const x = pad.l + i * stepX;
            const y = pad.t + (1 - Number(s.revenue || 0) / max) * (h - pad.t - pad.b);
            return [x, y];
        });
        const line = points.map((p, i) => `${i === 0 ? "M" : "L"}${p[0].toFixed(1)},${p[1].toFixed(1)}`).join(" ");
        const area = `${line} L${points.at(-1)[0].toFixed(1)},${h - pad.b} L${points[0][0].toFixed(1)},${h - pad.b} Z`;
        const labels = series
            .filter((_, i) => series.length <= 14 || i % Math.ceil(series.length / 8) === 0)
            .map((s) => {
                const i = series.indexOf(s);
                const x = pad.l + i * stepX;
                return `<text x="${x}" y="${h - 8}" text-anchor="middle" font-size="10" fill="#6b7a99">${esc(s.label)}</text>`;
            })
            .join("");
        el.innerHTML = `<svg viewBox="0 0 ${w} ${h}" role="img" aria-label="منحنى الإيرادات">
            <defs>
                <linearGradient id="repFill" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stop-color="#003399" stop-opacity="0.28"/>
                    <stop offset="100%" stop-color="#003399" stop-opacity="0.02"/>
                </linearGradient>
            </defs>
            <path d="${area}" fill="url(#repFill)"/>
            <path d="${line}" fill="none" stroke="#003399" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
            ${points
                .map(
                    (p, i) =>
                        `<circle cx="${p[0]}" cy="${p[1]}" r="3" fill="#fff" stroke="#003399" stroke-width="2">
                            <title>${esc(series[i].date)} — ${money(series[i].revenue)}</title>
                        </circle>`,
                )
                .join("")}
            ${labels}
        </svg>`;
    };

    const activateTab = (tab) => {
        state.tab = tab;
        hub.dataset.tab = tab;
        hub.querySelectorAll("[data-report-tab]").forEach((btn) => {
            const active = btn.getAttribute("data-report-tab") === tab;
            btn.classList.toggle("is-active", active);
            btn.setAttribute("aria-selected", active ? "true" : "false");
        });
        hub.querySelectorAll("[data-report-panel]").forEach((panel) => {
            const active = panel.getAttribute("data-report-panel") === tab;
            panel.classList.toggle("is-active", active);
            panel.hidden = !active;
        });
        const tabInput = hub.querySelector("[data-report-tab-input]");
        if (tabInput) tabInput.value = tab;
        const url = new URL(window.location.href);
        url.searchParams.set("tab", tab);
        url.searchParams.set("preset", state.preset);
        url.searchParams.set("from", state.from);
        url.searchParams.set("to", state.to);
        window.history.replaceState({}, "", url);
        loadTab(tab);
    };

    const renderKpis = (kpis) => {
        const wrap = hub.querySelector("[data-report-kpis]");
        if (!wrap || !kpis) return;
        wrap.innerHTML = kpis
            .map((kpi) => {
                const formatted =
                    kpi.format === "money"
                        ? money(kpi.value)
                        : kpi.format === "percent"
                          ? `${Number(kpi.value).toLocaleString("en-US", { maximumFractionDigits: 1 })}%`
                          : num(kpi.value);
                const deltaClass = kpi.delta === null ? "is-flat" : kpi.delta >= 0 ? "is-up" : "is-down";
                const icon =
                    kpi.delta === null ? "bi-dash" : kpi.delta >= 0 ? "bi-arrow-up-short" : "bi-arrow-down-short";
                return `<div class="col-6 col-md-4 col-xl-3">
                    <div class="reports-kpi reports-kpi--${esc(kpi.tone)}">
                        <div class="reports-kpi__icon"><i class="bi ${esc(kpi.icon)}"></i></div>
                        <div class="reports-kpi__body">
                            <div class="reports-kpi__label">${esc(kpi.label)}</div>
                            <div class="reports-kpi__value">${esc(formatted)}</div>
                            <div class="reports-kpi__delta ${deltaClass}">
                                <i class="bi ${icon}"></i> ${esc(kpi.delta_label)}
                                <span>مقابل الفترة السابقة</span>
                            </div>
                        </div>
                    </div>
                </div>`;
            })
            .join("");
    };

    const renderOverview = (data) => {
        renderKpis(data.kpis);
        renderSalesChart(hub.querySelector("[data-report-sales-chart]"), data.series || []);
        renderBars(hub.querySelector("[data-report-status-bars]"), data.status || []);
        const seriesLabel = hub.querySelector("[data-report-series-label]");
        if (seriesLabel) {
            seriesLabel.textContent = data.is_hourly ? "ساعي" : "يومي";
        }
        const topP = hub.querySelector("[data-report-top-products]");
        if (topP) {
            topP.innerHTML = (data.top_products || []).length
                ? data.top_products
                      .map(
                          (r, i) => `<tr>
                        <td class="text-muted">${esc(r.rank || i + 1)}</td>
                        <td class="fw-semibold">${esc(r.name)}</td>
                        <td>${num(r.qty)}</td>
                        <td>${money(r.revenue)}</td>
                    </tr>`,
                      )
                      .join("")
                : `<tr><td colspan="4" class="text-muted">لا بيانات في هذه الفترة.</td></tr>`;
        }
        const topC = hub.querySelector("[data-report-top-customers]");
        if (topC) {
            topC.innerHTML = (data.top_customers || []).length
                ? data.top_customers
                      .map(
                          (r, i) => `<tr>
                        <td class="text-muted">${esc(r.rank || i + 1)}</td>
                        <td><div class="fw-semibold">${esc(r.name)}</div><small class="text-muted">${esc(r.tier || "")} · ${esc(r.phone || "")}</small></td>
                        <td>${num(r.orders)}</td>
                        <td>${money(r.spent)}</td>
                    </tr>`,
                      )
                      .join("")
                : `<tr><td colspan="4" class="text-muted">لا بيانات في هذه الفترة.</td></tr>`;
        }
    };

    const tierClass = (tier) => {
        if (tier === "ذهبي") return "is-gold";
        if (tier === "فضي") return "is-silver";
        if (tier === "برونزي") return "is-bronze";
        return "is-new";
    };

    const renderDaily = (data) => {
        if (!data) return;
        const dateEl = hub.querySelector("[data-report-daily-date]");
        if (dateEl) dateEl.textContent = data.date_label || data.date || "";
        const compareEl = hub.querySelector("[data-report-daily-compare]");
        if (compareEl) compareEl.textContent = data.compared_to || "مقارنة بأمس";

        const kpiWrap = hub.querySelector("[data-report-daily-kpis]");
        if (kpiWrap && data.kpis) {
            kpiWrap.innerHTML = data.kpis
                .map((kpi) => {
                    const formatted =
                        kpi.format === "money"
                            ? money(kpi.value)
                            : kpi.format === "percent"
                              ? `${Number(kpi.value).toLocaleString("en-US", { maximumFractionDigits: 1 })}%`
                              : num(kpi.value);
                    const deltaClass = kpi.delta === null ? "is-flat" : kpi.delta >= 0 ? "is-up" : "is-down";
                    const icon =
                        kpi.delta === null ? "bi-dash" : kpi.delta >= 0 ? "bi-arrow-up-short" : "bi-arrow-down-short";
                    return `<div class="col-6 col-md-4 col-xl-2">
                        <div class="reports-kpi reports-kpi--${esc(kpi.tone)}">
                            <div class="reports-kpi__icon"><i class="bi ${esc(kpi.icon)}"></i></div>
                            <div class="reports-kpi__body">
                                <div class="reports-kpi__label">${esc(kpi.label)}</div>
                                <div class="reports-kpi__value">${esc(formatted)}</div>
                                <div class="reports-kpi__delta ${deltaClass}">
                                    <i class="bi ${icon}"></i> ${esc(kpi.delta_label)}
                                    <span>مقابل أمس</span>
                                </div>
                            </div>
                        </div>
                    </div>`;
                })
                .join("");
        }

        renderSalesChart(hub.querySelector("[data-report-hourly-chart]"), data.hourly || []);
        renderBars(hub.querySelector("[data-report-daily-status]"), data.status || []);

        const productsEl = hub.querySelector("[data-report-daily-products]");
        if (productsEl) {
            productsEl.innerHTML = (data.top_products || []).length
                ? data.top_products
                      .map(
                          (r, i) => `<tr>
                        <td class="text-muted">${esc(r.rank || i + 1)}</td>
                        <td class="fw-semibold">${esc(r.name)}</td>
                        <td>${num(r.qty)}</td>
                        <td>${money(r.revenue)}</td>
                    </tr>`,
                      )
                      .join("")
                : `<tr><td colspan="4" class="text-muted">لا مبيعات مسجّلة اليوم بعد.</td></tr>`;
        }

        const customersEl = hub.querySelector("[data-report-daily-customers]");
        if (customersEl) {
            customersEl.innerHTML = (data.top_customers || []).length
                ? data.top_customers
                      .map(
                          (r, i) => `<tr>
                        <td class="text-muted">${esc(r.rank || i + 1)}</td>
                        <td><div class="fw-semibold">${esc(r.name)}</div><small class="text-muted">${esc(r.tier || "")} · ${esc(r.phone || "")}</small></td>
                        <td>${num(r.orders)}</td>
                        <td>${money(r.spent)}</td>
                    </tr>`,
                      )
                      .join("")
                : `<tr><td colspan="4" class="text-muted">لا طلبات عملاء اليوم بعد.</td></tr>`;
        }

        const ordersEl = hub.querySelector("[data-report-daily-orders]");
        if (ordersEl) {
            ordersEl.innerHTML = (data.recent_orders || []).length
                ? data.recent_orders
                      .map(
                          (r) => `<tr>
                        <td class="fw-semibold">${esc(r.order_number)}</td>
                        <td>${esc(r.customer || "—")}</td>
                        <td><span class="badge text-bg-light">${esc(r.status_label || "")}</span></td>
                        <td>${money(r.total)}</td>
                        <td>${esc(r.created_at || "")}</td>
                        <td><a class="btn btn-sm btn-outline-success rounded-pill" href="${esc(r.edit_url)}">فتح</a></td>
                    </tr>`,
                      )
                      .join("")
                : `<tr><td colspan="6" class="text-muted text-center py-3">لا طلبات لهذا اليوم.</td></tr>`;
        }
    };

    const sortClient = (key, sortKey, dir) => {
        const rows = [...(state.client[key] || [])];
        rows.sort((a, b) => {
            const av = a[sortKey];
            const bv = b[sortKey];
            if (typeof av === "number" || typeof bv === "number") {
                return dir === "asc" ? Number(av) - Number(bv) : Number(bv) - Number(av);
            }
            return dir === "asc"
                ? String(av ?? "").localeCompare(String(bv ?? ""), "ar")
                : String(bv ?? "").localeCompare(String(av ?? ""), "ar");
        });
        state.client[key] = rows;
        return rows;
    };

    const filterClient = (key, q) => {
        const needle = (q || "").trim().toLowerCase();
        const rows = state.client[key] || [];
        if (!needle) return rows;
        return rows.filter((row) => JSON.stringify(row).toLowerCase().includes(needle));
    };

    const paintProducts = (rows) => {
        const el = hub.querySelector("[data-report-products-rows]");
        if (!el) return;
        el.innerHTML = rows.length
            ? rows
                  .map(
                      (r, i) => `<tr data-search>
                    <td class="text-muted">${esc(r.rank || i + 1)}</td>
                    <td class="fw-semibold">${esc(r.name)}</td>
                    <td>${num(r.qty)}</td>
                    <td>${money(r.revenue)}</td>
                    <td>${num(r.orders)}</td>
                </tr>`,
                  )
                  .join("")
            : `<tr><td colspan="5" class="text-muted">لا بيانات.</td></tr>`;
    };

    const paintCustomers = (rows) => {
        const el = hub.querySelector("[data-report-customers-rows]");
        if (!el) return;
        el.innerHTML = rows.length
            ? rows
                  .map(
                      (r, i) => `<tr>
                    <td class="text-muted">${esc(r.rank || i + 1)}</td>
                    <td class="fw-semibold">${esc(r.name)}</td>
                    <td>${esc(r.phone || "—")}</td>
                    <td>${num(r.orders)}</td>
                    <td>${num(r.delivered || 0)}</td>
                    <td>${money(r.spent)}</td>
                    <td>${num(r.loyalty || 0)}</td>
                    <td><span class="reports-tier ${tierClass(r.tier)}">${esc(r.tier || "—")}</span></td>
                    <td>${esc(r.last_order_at || "—")}</td>
                </tr>`,
                  )
                  .join("")
            : `<tr><td colspan="9" class="text-muted">لا بيانات.</td></tr>`;
    };

    const paintCouriers = (rows) => {
        const el = hub.querySelector("[data-report-couriers-rows]");
        if (!el) return;
        el.innerHTML = rows.length
            ? rows
                  .map(
                      (r) => `<tr>
                    <td>
                        <div class="fw-semibold">${esc(r.name)}</div>
                        <small class="text-muted">${esc(r.phone || "")}</small>
                    </td>
                    <td>${num(r.orders)}</td>
                    <td>${num(r.delivered)}</td>
                    <td>${num(r.cancelled)}</td>
                    <td>${money(r.revenue)}</td>
                    <td>
                        ${r.is_online ? '<span class="badge text-bg-success">متصل</span>' : '<span class="badge text-bg-secondary">غير متصل</span>'}
                        ${r.is_active ? "" : '<span class="badge text-bg-warning">موقوف</span>'}
                    </td>
                </tr>`,
                  )
                  .join("")
            : `<tr><td colspan="6" class="text-muted">لا بيانات.</td></tr>`;
    };

    const paintInventory = (summary, rows) => {
        const kpis = hub.querySelector("[data-report-inventory-kpis]");
        if (kpis && summary) {
            const cards = [
                ["إجمالي المنتجات", num(summary.total), "bi-box-seam"],
                ["نفد المخزون", num(summary.out_of_stock), "bi-x-octagon"],
                ["منخفض", num(summary.low_stock), "bi-exclamation-triangle"],
                ["قيمة المخزون", money(summary.inventory_value), "bi-cash-stack"],
            ];
            kpis.innerHTML = cards
                .map(
                    ([label, value, icon]) => `<div class="col-6 col-md-3">
                    <div class="reports-kpi">
                        <div class="reports-kpi__icon"><i class="bi ${icon}"></i></div>
                        <div><div class="reports-kpi__label">${label}</div><div class="reports-kpi__value">${value}</div></div>
                    </div>
                </div>`,
                )
                .join("");
        }
        const el = hub.querySelector("[data-report-inventory-rows]");
        if (!el) return;
        el.innerHTML = rows.length
            ? rows
                  .map((r) => {
                      const badge =
                          r.stock <= 0
                              ? '<span class="reports-stock-badge is-out">نفد</span>'
                              : '<span class="reports-stock-badge is-low">منخفض</span>';
                      return `<tr>
                        <td class="fw-semibold">${esc(r.name)}</td>
                        <td>${esc(r.category || "—")}</td>
                        <td>${num(r.stock)} ${badge}</td>
                        <td>${money(r.price)}</td>
                        <td>${r.is_active ? "نشط" : "مخفي"}</td>
                    </tr>`;
                  })
                  .join("")
            : `<tr><td colspan="5" class="text-muted">لا منتجات منخفضة المخزون.</td></tr>`;
    };

    const paintCoupons = (rows) => {
        const el = hub.querySelector("[data-report-coupons-rows]");
        if (!el) return;
        el.innerHTML = rows.length
            ? rows
                  .map(
                      (r) => `<tr>
                    <td class="fw-semibold">${esc(r.code)}</td>
                    <td>${esc(r.title || "—")}</td>
                    <td>${num(r.uses)}</td>
                    <td>${money(r.discount_total)}</td>
                    <td>${money(r.order_total)}</td>
                    <td>${r.is_active ? "نعم" : "لا"}</td>
                </tr>`,
                  )
                  .join("")
            : `<tr><td colspan="6" class="text-muted">لا بيانات.</td></tr>`;
    };

    const paintSales = (data) => {
        renderSalesChart(hub.querySelector("[data-report-sales-chart-full]"), data.series || []);
        renderBars(hub.querySelector("[data-report-payment-bars]"), data.payments || [], "count");
        renderBars(hub.querySelector("[data-report-method-bars]"), data.methods || [], "count");
        state.client.sales = data.series || [];
        const el = hub.querySelector("[data-report-sales-rows]");
        if (!el) return;
        el.innerHTML = state.client.sales
            .map(
                (r) => `<tr>
                <td>${esc(r.date)}</td>
                <td>${money(r.revenue)}</td>
                <td>${num(r.orders)}</td>
            </tr>`,
            )
            .join("");
    };

    const paintOrders = (table) => {
        const el = hub.querySelector("[data-report-orders-rows]");
        const pager = hub.querySelector("[data-report-orders-pager]");
        if (!el) return;
        const rows = table?.data || [];
        el.innerHTML = rows.length
            ? rows
                  .map(
                      (r) => `<tr>
                    <td class="fw-semibold">${esc(r.order_number)}</td>
                    <td>${esc(r.customer || "—")}<div class="small text-muted">${esc(r.phone || "")}</div></td>
                    <td>${esc(r.courier || "—")}</td>
                    <td><span class="badge text-bg-light">${esc(r.status_label || r.status)}</span></td>
                    <td>${esc(r.payment || "—")}</td>
                    <td class="fw-bold">${money(r.total)}</td>
                    <td>${esc(r.created_at || "")}</td>
                    <td><a class="btn btn-sm btn-outline-success rounded-pill" href="${esc(r.edit_url)}">فتح</a></td>
                </tr>`,
                  )
                  .join("")
            : `<tr><td colspan="8" class="text-muted text-center py-4">لا طلبات مطابقة.</td></tr>`;
        if (pager) {
            const current = table.current_page || 1;
            const last = table.last_page || 1;
            pager.innerHTML = `
                <span class="small text-muted">${num(table.total || 0)} طلب — صفحة ${current} من ${last}</span>
                <div class="d-flex gap-2">
                    <button type="button" class="btn btn-sm btn-outline-secondary rounded-pill" data-orders-page="${current - 1}" ${current <= 1 ? "disabled" : ""}>السابق</button>
                    <button type="button" class="btn btn-sm btn-outline-secondary rounded-pill" data-orders-page="${current + 1}" ${current >= last ? "disabled" : ""}>التالي</button>
                </div>`;
        }
    };

    const paintReviews = (data) => {
        const avg = hub.querySelector("[data-report-reviews-avg]");
        const count = hub.querySelector("[data-report-reviews-count]");
        if (avg) avg.textContent = Number(data.avg_rating || 0).toFixed(2);
        if (count) count.textContent = `${num(data.count || 0)} تقييم في الفترة`;
        renderBars(
            hub.querySelector("[data-report-reviews-bars]"),
            (data.distribution || []).map((d) => ({
                label: `${d.rating} ★`,
                count: d.count,
            })),
            "count",
        );
    };

    const loadTab = async (tab) => {
        if (tab === "daily") {
            if (state.cache.daily) {
                renderDaily(state.cache.daily);
            }
            const res = await fetchSection("daily");
            state.cache.daily = res.data;
            renderDaily(res.data);
            return;
        }
        if (tab === "overview") {
            if (state.cache.overview?.kpis) {
                renderOverview(state.cache.overview);
            }
            const res = await fetchSection("overview");
            state.cache.overview = res.data;
            renderOverview(res.data);
            return;
        }
        if (tab === "sales") {
            const res = await fetchSection("sales");
            paintSales(res.data);
            return;
        }
        if (tab === "orders") {
            await loadOrders();
            return;
        }
        if (tab === "products") {
            const res = await fetchSection("products");
            state.client.products = res.data.items || [];
            paintProducts(state.client.products);
            return;
        }
        if (tab === "customers") {
            const res = await fetchSection("customers");
            state.client.customers = res.data.items || [];
            paintCustomers(state.client.customers);
            return;
        }
        if (tab === "couriers") {
            const res = await fetchSection("couriers");
            state.client.couriers = res.data.items || [];
            paintCouriers(state.client.couriers);
            return;
        }
        if (tab === "inventory") {
            const res = await fetchSection("inventory");
            state.client.inventory = res.data.items || [];
            paintInventory(res.data.summary, state.client.inventory);
            return;
        }
        if (tab === "coupons") {
            const res = await fetchSection("coupons");
            state.client.coupons = res.data.items || [];
            paintCoupons(state.client.coupons);
            return;
        }
        if (tab === "reviews") {
            const res = await fetchSection("reviews");
            paintReviews(res.data);
        }
    };

    const loadOrders = async () => {
        const res = await fetchSection("orders", {
            q: state.orders.q,
            status: state.orders.status,
            sort: state.orders.sort,
            dir: state.orders.dir,
            page: state.orders.page,
            per_page: state.orders.per_page,
        });
        paintOrders(res.data.table);
    };

    hub.querySelectorAll("[data-report-tab]").forEach((btn) => {
        btn.addEventListener("click", () => activateTab(btn.getAttribute("data-report-tab")));
    });

    hub.querySelector("[data-report-refresh]")?.addEventListener("click", () => {
        state.cache = {};
        loadTab(state.tab);
    });

    hub.querySelector("[data-report-print]")?.addEventListener("click", () => window.print());

    let ordersTimer;
    hub.querySelector("[data-report-orders-q]")?.addEventListener("input", (event) => {
        clearTimeout(ordersTimer);
        ordersTimer = setTimeout(() => {
            state.orders.q = event.target.value;
            state.orders.page = 1;
            loadOrders();
        }, 280);
    });
    hub.querySelector("[data-report-orders-status]")?.addEventListener("change", (event) => {
        state.orders.status = event.target.value;
        state.orders.page = 1;
        loadOrders();
    });
    hub.querySelector("[data-report-orders-per-page]")?.addEventListener("change", (event) => {
        state.orders.per_page = Number(event.target.value) || 25;
        state.orders.page = 1;
        loadOrders();
    });
    hub.addEventListener("click", (event) => {
        const pageBtn = event.target.closest("[data-orders-page]");
        if (pageBtn) {
            const page = Number(pageBtn.getAttribute("data-orders-page"));
            if (page >= 1) {
                state.orders.page = page;
                loadOrders();
            }
            return;
        }
        const sortBtn = event.target.closest("[data-orders-sort]");
        if (sortBtn) {
            const key = sortBtn.getAttribute("data-orders-sort");
            if (state.orders.sort === key) {
                state.orders.dir = state.orders.dir === "asc" ? "desc" : "asc";
            } else {
                state.orders.sort = key;
                state.orders.dir = "desc";
            }
            hub.querySelectorAll("[data-orders-sort]").forEach((b) => b.classList.remove("is-active"));
            sortBtn.classList.add("is-active");
            loadOrders();
        }
    });

    hub.querySelectorAll("[data-client-filter]").forEach((input) => {
        input.addEventListener("input", () => {
            const key = input.getAttribute("data-client-filter");
            const rows = filterClient(key, input.value);
            if (key === "products") paintProducts(rows);
            if (key === "customers") paintCustomers(rows);
            if (key === "inventory") paintInventory(null, rows);
        });
    });

    hub.querySelectorAll("[data-report-sortable]").forEach((table) => {
        table.querySelectorAll("th[data-sort]").forEach((th) => {
            th.style.cursor = "pointer";
            th.addEventListener("click", () => {
                const key = table.getAttribute("data-client-table");
                if (!key || !state.client[key]) return;
                const sortKey = th.getAttribute("data-sort");
                const dir = th.dataset.dir === "asc" ? "desc" : "asc";
                th.dataset.dir = dir;
                const rows = sortClient(key, sortKey, dir);
                if (key === "products") paintProducts(rows);
                if (key === "customers") paintCustomers(rows);
                if (key === "couriers") paintCouriers(rows);
                if (key === "inventory") paintInventory(null, rows);
                if (key === "coupons") paintCoupons(rows);
            });
        });
    });

    document.querySelectorAll("[data-report-export]").forEach((btn) => {
        btn.addEventListener("click", () => {
            const format = btn.getAttribute("data-report-export");
            const type =
                document.querySelector('#reportExportModal input[name="export_type"]:checked')?.value || "overview";
            const url = `${hub.dataset.exportUrl}?${queryString(params({ type, format }))}`;
            window.location.href = url;
        });
    });

    hub.querySelector("[data-report-save-preset]")?.addEventListener("click", () => {
        const preset = {
            preset: state.preset,
            from: state.from,
            to: state.to,
            tab: state.tab,
            saved_at: new Date().toISOString(),
        };
        const blob = new Blob([JSON.stringify(preset, null, 2)], { type: "application/json" });
        const a = document.createElement("a");
        a.href = URL.createObjectURL(blob);
        a.download = `report-preset-${state.from}-${state.to}.json`;
        a.click();
        URL.revokeObjectURL(a.href);
    });

    const importForm = document.querySelector("[data-report-import-form]");
    importForm?.addEventListener("submit", async (event) => {
        event.preventDefault();
        const errorEl = importForm.querySelector("[data-report-import-error]");
        if (errorEl) {
            errorEl.hidden = true;
            errorEl.textContent = "";
        }
        const formData = new FormData(importForm);
        try {
            const { data } = await window.axios.post(hub.dataset.importUrl, formData);
            if (data.redirect) {
                window.location.href = data.redirect;
                return;
            }
            throw new Error(data.message || "فشل الاستيراد");
        } catch (err) {
            const message = err?.response?.data?.message || err.message || "تعذر استيراد الملف.";
            if (errorEl) {
                errorEl.hidden = false;
                errorEl.textContent = message;
            }
        }
    });

    // Initial paint from server-provided overview, then hydrate active tab.
    if (state.cache.daily) {
        renderDaily(state.cache.daily);
    }
    if (state.cache.overview?.kpis) {
        renderOverview(state.cache.overview);
        renderSalesChart(hub.querySelector("[data-report-sales-chart]"), state.cache.overview.series || []);
        renderBars(hub.querySelector("[data-report-status-bars]"), state.cache.overview.status || []);
    }
    loadTab(state.tab);
};

bindReportsHub();
window.addEventListener("admin:content-ready", bindReportsHub);

const syncPromoBulkSelection = (root = document) => {
    const wrap = root.querySelector?.("[data-promo-bulk]") || document.querySelector("[data-promo-bulk]");
    if (!wrap) {
        return;
    }
    const boxes = [...wrap.querySelectorAll("[data-promo-select]")];
    const selected = boxes.filter((box) => box.checked);
    const all = wrap.querySelector("[data-promo-select-all]");
    if (all) {
        all.checked = boxes.length > 0 && selected.length === boxes.length;
        all.indeterminate = selected.length > 0 && selected.length < boxes.length;
    }
    const btn = wrap.querySelector("[data-promo-bulk-selected]");
    if (btn) {
        btn.disabled = selected.length === 0;
    }
};

document.addEventListener("change", (event) => {
    const all = event.target.closest("[data-promo-select-all]");
    if (all) {
        const wrap = all.closest("[data-promo-bulk]");
        wrap?.querySelectorAll("[data-promo-select]").forEach((box) => {
            box.checked = all.checked;
        });
        syncPromoBulkSelection(wrap || document);
        return;
    }
    if (event.target.closest("[data-promo-select]")) {
        syncPromoBulkSelection(event.target.closest("[data-promo-bulk]") || document);
    }
});

syncPromoBulkSelection();
window.addEventListener("admin:content-ready", () => syncPromoBulkSelection());

