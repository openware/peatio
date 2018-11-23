$(document).ready(function () {

  setSidebarHeight();
  initPerfectScrollbar();
  closeSidebarWithClick();
  closeSidebarOnSmallScreen();
});

$( window ).resize(function() {
  setSidebarHeight();
  closeSidebarOnSmallScreen();
});


function setSidebarHeight() {
  var sidebarHeight = $('body').height() - $('.sidebar-header ').height();
  $('.sidebar-content').height(sidebarHeight);
};

function initPerfectScrollbar() {
  new PerfectScrollbar('.has-scrollbar', {
    wheelSpeed: 2,
    wheelPropagation: true,
    minScrollbarLength: 20
  });
};

function closeSidebarWithClick() {
  $('#sidebarCollapse').on('click', function () {
    if (!$('body').hasClass('sidebar-closed')) {
      $('body').addClass('sidebar-closed-by-user');
      closeSidebar();
    } else {
      $('body').removeClass('sidebar-closed-by-user');
      openSidebar();
    }
  });
}

function closeSidebarOnSmallScreen() {
  if ($(this).width() <= 992) {
    closeSidebar();
    $('.hide-on-closed-sidebar').hide();
  } else {
    $('.hide-on-closed-sidebar').show();
    if (!$('body').hasClass('sidebar-closed-by-user')) {
      openSidebar();
    }
  }
}

function closeSidebar() {
  $('body').addClass('sidebar-closed');
  $('.admin-header .toggle-sidebar-icon').addClass('fa-caret-right');
  $('.has-sub-menu').popover('hide');
  $('.nested-child-popover').popover('hide');
}

function openSidebar() {
  $('body').removeClass('sidebar-closed');
  $('.admin-header .toggle-sidebar-icon').removeClass('fa-caret-right');
  $('.has-sub-menu').popover('hide');
  $('.nested-child-popover').popover('hide');
}

function displayNestedChild(e) {
  $('.nested-child-popover').not(e).popover('hide');
  $(e).attr('data-html', true);
  $(e).attr('data-content',$(e).next('.sub-menu').html()).popover('show');
}

// Show/Hide popovers
$(function () {
  $(".dashboard-sidebar .has-sub-menu").each(function(i, obj) {
    $(this).popover({
      html: true,
      content: function() { return $(this).next('.sub-menu').html(); }
    });
  });

  $(".dashboard-sidebar .nested-child-popover").each(function(i, obj) {
      $(this).popover({
          html: true,
          trigger: 'manual'
      });
  });

  $(".has-sub-menu").on('click', function(e) {
    $('.has-sub-menu').not(this).popover('hide');
    $('.nested-child-popover').popover('hide');
  });
});

