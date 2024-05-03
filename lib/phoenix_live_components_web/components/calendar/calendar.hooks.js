let CalendarHooks = {
    mounted: function() {
        this.handleEvent("change_calendar_value", (name_object) => change_calendar_value_event(name_object.name, name_object.value ))
    },

    updated: function () {
        window.pushEventHook = this
        let mode = this.el.getAttribute('phx-value-mode');

        if (mode === "range") {
            let available_days = this.el.getElementsByClassName('available-day')
            let unavailable_days = this.el.getElementsByClassName('unavailable-day')
            let default_grid_view = document.getElementsByName("default-grid-view");

            Array.from(available_days).forEach((hover_elem) => hover_elem.addEventListener("mouseenter", () => {
                let available_days = this.el.getElementsByClassName('available-day');
                Array.from(available_days).forEach((elem) => {
                    let this_date = hover_elem.getAttribute('phx-value-date').concat("Z");
                    let element_date = elem.getAttribute('phx-value-date').concat("Z");
                    let start_date = elem.getAttribute('phx-value-start_date').concat("Z");

                    set_bg_by_condition(elem, (isAfterStartDate(element_date, start_date) && isBeforeThatDate(element_date, this_date)))
                })
            }))

            Array.from(default_grid_view).forEach((hover_elem) => hover_elem.addEventListener("mouseleave", () => {
                let available_days = this.el.getElementsByClassName('available-day');
                Array.from(available_days).forEach((elem) => reset_selection(elem))
            }))

            Array.from(unavailable_days).forEach((hover_elem) => hover_elem.addEventListener("mouseleave", () => {
                let available_days = this.el.getElementsByClassName('available-day');
                Array.from(available_days).forEach((elem) => reset_selection(elem))
            }))

        }
    }
};

let set_bg_by_condition = (element, condition) => condition ? element.classList.add("bg-blue-100", 'text-white') : element.classList.remove("bg-blue-100", 'text-white');

let reset_selection = (element) => {
    let element_date = element.getAttribute('phx-value-date').concat("Z");
    let start_date = element.getAttribute('phx-value-start_date').concat("Z");
    let end_date = element.getAttribute('phx-value-end_date').concat("Z");
    let start_end_condition = (start_date !== "emptyZ") && (end_date !== "emptyZ")
    console.log("start_date", start_date)
    console.log("end_date", end_date)
    set_bg_by_condition(element, start_end_condition && (isAfterStartDate(element_date, start_date) && isBeforeThatDate(element_date, end_date)))
}

let getValueOfDate = (dateString) => {
    return new Date(dateString).valueOf()
}
let isAfterStartDate = (day, startDate) => {
    return getValueOfDate(day) >= getValueOfDate(startDate)
}
let isBeforeThatDate = (day, hoverDate) => {
    return getValueOfDate(day) <= getValueOfDate(hoverDate)
}

const change_calendar_value_event = (input_name,input_value) => {
    let str_selector = 'input[name="' + input_name + '"]'
    let elem = document.querySelector(str_selector)
    elem && (elem.value = input_value)
}

export {CalendarHooks};
