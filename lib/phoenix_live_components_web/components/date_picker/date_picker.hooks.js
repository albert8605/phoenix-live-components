let DatePickerChange = {
  mounted: function() {
   this.handleEvent("change_calendar_value", (name_object) => change_calendar_value_event(name_object.name, name_object.value ))
  }
};

const change_calendar_value_event = (input_name,input_value) => {
    let str_selector = 'input[name="' + input_name + '"]'
    let elem = document.querySelector(str_selector)

    elem && (elem.value = input_value)
    &&
    // setTimeout( function () {
        elem.dispatchEvent(new Event("input", {bubbles: true}))
            // },
        // 200
    // )
}

export {DatePickerChange};
