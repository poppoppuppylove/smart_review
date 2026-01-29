import { createRouter, createWebHistory } from 'vue-router'
import Login from '../views/Login.vue'
import Register from '../views/Register.vue'
import QuestionImport from '../views/QuestionImport.vue'
import Practice from '../views/Practice.vue'
import QuestionSetList from '../views/QuestionSetList.vue'
import QuestionSetDetail from '../views/QuestionSetDetail.vue'
import WrongBook from '../views/WrongBook.vue'
import ReviewPlan from '../views/ReviewPlan.vue'
import Statistics from '../views/Statistics.vue'

const routes = [
    {
        path: '/',
        redirect: '/login'
    },
    {
        path: '/login',
        name: 'Login',
        component: Login,
        meta: { guest: true }
    },
    {
        path: '/register',
        name: 'Register',
        component: Register,
        meta: { guest: true }
    },
    {
        path: '/import',
        name: 'QuestionImport',
        component: QuestionImport,
        meta: { requiresAuth: true }
    },
    {
        path: '/practice',
        name: 'Practice',
        component: Practice,
        meta: { requiresAuth: true }
    },
    {
        path: '/question-sets',
        name: 'QuestionSetList',
        component: QuestionSetList,
        meta: { requiresAuth: true }
    },
    {
        path: '/question-sets/:id',
        name: 'QuestionSetDetail',
        component: QuestionSetDetail,
        meta: { requiresAuth: true }
    },
    {
        path: '/wrong',
        name: 'WrongBook',
        component: WrongBook,
        meta: { requiresAuth: true }
    },
    {
        path: '/review',
        name: 'ReviewPlan',
        component: ReviewPlan,
        meta: { requiresAuth: true }
    },
    {
        path: '/statistics',
        name: 'Statistics',
        component: Statistics,
        meta: { requiresAuth: true }
    }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
    const isLoggedIn = localStorage.getItem('isLoggedIn') === 'true'

    // 如果页面需要登录但用户未登录,跳转到登录页
    if (to.meta.requiresAuth && !isLoggedIn) {
        next('/login')
    }
    // 如果用户已登录但访问登录页,跳转到首页
    else if (to.meta.guest && isLoggedIn) {
        next('/import')
    }
    else {
        next()
    }
})

export default router
