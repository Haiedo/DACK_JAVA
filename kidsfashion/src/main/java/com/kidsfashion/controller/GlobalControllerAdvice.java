package com.kidsfashion.controller;

import com.kidsfashion.model.User;
import com.kidsfashion.service.CartService;
import com.kidsfashion.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class GlobalControllerAdvice {

    @Autowired private CartService cartService;
    @Autowired private UserService userService;

    @ModelAttribute
    public void addAttributes(Model model, Authentication auth, HttpSession session, HttpServletRequest request) {
        String uri = request.getRequestURI();

        // NẾU LÀ TRANG LỖI HOẶC TRANG LOGIN THÌ DỪNG NGAY (THOÁT LOOP)
        if (uri.contains("/error") || uri.contains("/login") || uri.contains("/images") || uri.contains("/uploads")) {
            return;
        }

        if (auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getPrincipal().toString())) {
            try {
                User user = userService.findByUsername(auth.getName()).orElse(null);
                if (user != null) {
                    model.addAttribute("user", user);
                    // Bọc giỏ hàng vào try-catch để nếu lỗi DB cũng không làm reload trang
                    try {
                        model.addAttribute("cartCount", cartService.getCartCount(user, session.getId()));
                    } catch (Exception e) {
                        model.addAttribute("cartCount", 0);
                    }
                }
            } catch (Exception e) {
                // Lỗi thì thôi, thoát ra để web hiện trang lỗi bình thường, không loop
            }
        }
    }
}