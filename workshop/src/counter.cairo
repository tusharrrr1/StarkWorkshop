// counter contract
#[starknet::interface]
trait ICounter<TContractState> {
    fn get_counter(self: @TContractState) -> u32;
    fn increase_counter(ref self: TContractState, _value: u32);
}

#[starknet::contract]
pub mod Counter {
    use core::starknet::event::EventEmitter;
#[storage]
    struct Storage {
        counter: u32
    }

    // this event will emit whenever the state variable counter increases
    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    struct CounterIncreased {
       #[key]
       pub value: u32
    }

    // event enum 
    #[event]
    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    pub enum Event {
        CounterIncreased: CounterIncreased
    }

    #[constructor]
    fn constructor(ref self: ContractState, _counter: u32) {
        self.counter.write(_counter);
    }

    #[abi(embed_v0)]
    impl counter_contract of super::ICounter<ContractState>{
        fn get_counter(self: @ContractState) -> u32 {
            return self.counter.read();
        }

        fn increase_counter(ref self: ContractState, _value: u32) {
            self.counter.write(_value);
            self.emit(Event::CounterIncreased(CounterIncreased{value: _value}));
        }
    }
}